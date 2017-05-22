function samp_and_saveMHz(psd_info)
%% Global variables
% global aline1; % animatedLine for fig1
% global aline2; % animatedLine for fig2
global fig1Index; % channel displayed in fig1
global fig2Index; % channel displayed in fig2
global fig_one; % Figure of fig1
global fig_two; % Figure of fig2
global fileMemory; % amount of memory files contain
global fileTime; % amount of time files contain
global initIRIG; % Time where only IRIG is sampled to get start time (seconds)
global initIRIGdata; % Where initial IRIG data is stored
global IRIGsampTime; % IRIG duration each file contains
global keepRunning; % GUI controlled variable to stop sampling
global myFid; % Current file being saved into
global myInfo; % All the information gathered by GUI
global sampR; % Sampling rate
global x; % x values to use for animatedLine
global mainLabel;
global scalingFactor;
global initIRIGConst;
global IRIGsampTimeConst;
global plotLive;

%% Initial variables
myInfo = psd_info;
if(myInfo.sampRate>1e6)
    scalingFactor = 10;
else
    scalingFactor = 1;
end
sampR = myInfo.sampRate / scalingFactor;
initIRIG = 2 * scalingFactor;
initIRIGConst = 2 * scalingFactor;
initIRIGdata = zeros(1,initIRIG*sampR);
IRIGsampTime = myInfo.IRIGtime *scalingFactor;
IRIGsampTimeConst = IRIGsampTime;
aChannels = myInfo.aChannels;
x = linspace(1,10,sampR);
fileMemory = myInfo.saveMemory;
fileTime = myInfo.saveTime;
mainLabel = myInfo.clock;

%% DAQ settings
daqreset;

d = daq.getDevices();
try
    name = d(1).ID;
    switch name
        case 'Dev1'
        otherwise
            cd('..');
            error('ERROR: Dev1 not found');
    end
    cardResolution = get_resolution(d);
    myInfo.cardResolution = cardResolution;
catch
    cd('..');
    error('ERROR: DAQ board not detected');
end

%% Create Session and add channels
s = daq.createSession('ni');
activeChans = find(aChannels == 1);
activeChans = activeChans - 1;
for k = activeChans
    addAnalogInputChannel(s, 'Dev1', ['ai' num2str(k)], 'Voltage');
end

% Add Clock and Trigger
addTriggerConnection(s, 'external', 'Dev1/PFI1', 'StartTrigger');
cc = addClockConnection(s, 'external', 'Dev1/PFI7', 'ScanClock');

% Session Settings
s.IsContinuous = true;
s.Rate = sampR;
lh1 = addlistener(s,'DataAvailable', @save_dataMHz);
lh2 = addlistener(s,'ErrorOccured', @(src, event) disp(getReport(event.Error)));
s.NotifyWhenDataAvailableExceeds = sampR;

%% Setting up plotting
if plotLive
    
    fig_one = psd_info.axes1;
    fig_two = psd_info.axes2;
    activeChans = activeChans(2:end);

    if myInfo.fig1Chan == 0
        fig_one_title = 'IRIG';
        fig1Index = 0;
    else
        fig_one_title = ['Ch' num2str(myInfo.fig1Chan)];
        fig1Index = find(activeChans == myInfo.fig1Chan);
    end

    if myInfo.fig2Chan ==0
        fig_two_title = 'IRIG';
        fig2Index = 0;
    else
        fig_two_title = ['Ch' num2str(myInfo.fig2Chan)];
        fig2Index = find(activeChans == myInfo.fig2Chan);
    end
    
    title(fig_one,['Measured Voltage of ' fig_one_title])
    ylabel(fig_one,'Voltage (V)')
    ylim(fig_one,[myInfo.ylow myInfo.yhigh])
    fig_one.YLimMode = 'manual';
    hold(fig_one,'on');
    
    title(fig_two,['Measured Voltage of ' fig_two_title])
    ylabel(fig_two,'Voltage (V)')
    ylim(fig_two,[myInfo.ylow myInfo.yhigh]);
    fig_two.YLimMode = 'manual';
    hold(fig_two,'on');
end

%% Begin sampling
s.startBackground();
fprintf('start sampling\n');

running = keepRunning;
while running
    if ~keepRunning
        running = keepRunning;
        s.stop;
        fprintf('Stopping\n');
    end
    pause(.01);
end
try
    fclose(myFid);
catch
    warning('Session stopped before IRIG acquired. No files created');
end
fprintf('Session stopped\n');
daqreset();
if plotLive
    cla(fig_one,'reset');
    cla(fig_two,'reset');
end
set(myInfo.clock,'String','00:00:00');
cd('..');