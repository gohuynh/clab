function samp_and_saveMHz(psd_info)
%% Global variables
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
global mainLabel; % Label for clock and other information
global uptimeLabel; % Label for uptime
global scalingFactor; % Scaling factor for sampling >= 1 MHz
global initIRIGConst; % Number of runs for 2 seconds worth of IRIG
global IRIGsampTimeConst; % Amount of IRIG to be saved for each file
global plotLive; % Boolean to live plot
global fileName; % Name of current file
global errorFid; % FID for error log
global saveFid; % FID for save log
global errorLogName; % Name of error log
global saveLogName; % Name of save log
global filesCreated; % Number of files created
global eof_IRIG;
global restart_session;

%% Initial variables
myInfo = psd_info;
if(myInfo.sampRate>1e6)
    scalingFactor = 10;
else
    scalingFactor = 1;
end
sampR = myInfo.sampRate / scalingFactor;
aChannels = myInfo.aChannels;
x = linspace(0,10,sampR);
% Saving Parameters
initIRIG = 2 * scalingFactor;
initIRIGConst = 2 * scalingFactor;
initIRIGdata = zeros(1,initIRIG*sampR);
IRIGsampTime = myInfo.IRIGtime *scalingFactor;
IRIGsampTimeConst = IRIGsampTime;
fileMemory = myInfo.saveMemory;
fileTime = myInfo.saveTime;
% Information Variables
mainLabel = myInfo.clock;
uptimeLabel = myInfo.uptime;
filesCreated = 0;
errorLogName = ['Logs/error_log_', datestr(datetime('now'),'yyyymmdd_HHMMSS'), '.txt'];
saveLogName = ['Logs/save_log_', datestr(datetime('now'),'yyyymmdd_HHMMSS'), '.txt'];
errorFid = fopen(errorLogName, 'wt');
saveFid = fopen(saveLogName, 'wt');
eof_IRIG = 0;
restart_session = 0;

%% Check for DAQ connection
daqreset;

try
    d = daq.getDevices();
    name = d(1).ID;
    switch name
        case 'Dev1'
        otherwise
            cd('..');
            error('ERROR: Dev1 not found');
    end
    myInfo.cardResolution = get_resolution(d);
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
addClockConnection(s, 'external', 'Dev1/PFI7', 'ScanClock');

% Session Settings
s.IsContinuous = true;
s.Rate = sampR;
addlistener(s,'DataAvailable', @save_dataMHz);
addlistener(s,'ErrorOccurred', @(src, event) disp(getReport(event.Error)));
s.NotifyWhenDataAvailableExceeds = sampR;

%% Set up plotting
if plotLive
    
    fig_one = psd_info.axes1;
    fig_two = psd_info.axes2;
    activeChans = activeChans(2:end);

    % Associate each figure with a channel
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
    
    % Set up plot details
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
    pause(.01); % NECESSARY PAUSE
end
%% End session
% Close most recent file
try
    fclose(myFid);
    % If not enough IRIG saved, delete file
    if IRIGsampTime ~= 0
        button = questdlg(sprintf('File %s does not have specified IRIG amount. Delete?', fileName), 'Small File', 'Yes', 'No', 'Yes');
        switch button
            case 'Yes'
                delete(fileName);
        end
    end
catch
    warning('Session stopped before IRIG acquired. No files created');
end
% Close logs
fclose(errorFid);
fclose(saveFid);
errorFileInfo = dir(errorLogName);
saveFileInfo = dir(saveLogName);
if errorFileInfo.bytes == 0
    delete(errorLogName);
end
if saveFileInfo.bytes ==0
    delete(saveLogName);
end
% Reset display
daqreset();
if plotLive
    cla(fig_one,'reset');
    cla(fig_two,'reset');
end
set(myInfo.clock,'String','00:00:00');
set(myInfo.uptime,'String','Files Created: n/a');
cd('..');
if restart_session
    startButton = myInfo.handles.startButton;
    startCallback = startButton.Callback;
    startCallback(startButton,[]);
    return;
end