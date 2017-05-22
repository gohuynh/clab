function save_data(src,event)
%% Global variables
global aline1; % animatedLine for fig1
global aline2; % animatedLine for fig2
global currTime; % Current time this code is called
global fig1Index; % channel displayed in fig1
global fig2Index; % channel displayed in fig2
global fileMemory; % amount of memory files contain
global fileTime; % amount of time files contain
global initIRIG; % Time where only IRIG is sampled to get start time (seconds)
global initIRIGdata; % Where initial IRIG data is stored
global IRIGsampTime; % IRIG duration each file contains
global myFid; % Current file being saved into
global myInfo; % All the information gathered by GUI
global sampR; % Sampling rate
global timeStart; % Initial time session began
global x; % x values to use for animatedLine
global mainLabel;

%% Seperate data from daq
data = event.Data';
irigData = data(1,:);
chanData = data(2:end,:);
fprintf('data in\n');
%% Find starting time
% Gather 2 seconds of IRIG to get initial time start
if initIRIG > 0
    initIRIGdata = [initIRIGdata irigData];
    set(mainLabel,'String',['IRIG Second: ' num2str(initIRIG)]);
    if myInfo.plotLive
        set(mainLabel,'String',['IRIG Second: ' num2str(initIRIG)]);
    end
    initIRIG = initIRIG - 1;
end
if initIRIG == 0
    %% Calculate and store initial start time
    initTime = get_irig_start_time_G(initIRIGdata,sampR,'IRIG-B');
    c = clock;
    year = c(1);
    jan1=strcat('01/01/',num2str(year));
    doy = initTime(1);
    startDate = datevec(addtodate(datenum(jan1), doy-1, 'day'));
    startDate = [startDate(1:3) initTime(2:end)];
    timeStart = datenum(startDate);
    timeStart = addtodate(timeStart,2,'second');
    currTime = timeStart;

    date = datevec(timeStart);
    myInfo.timeStart = datestr(date,'yyyy:mm:dd:HH:MM:SS:FFF');
    initIRIG = initIRIG - 1;
    fprintf('Time start acquired\n');
    fileName = strcat(myInfo.pn,'\',datestr(date,'yyyymmdd_HHMMSS_'),myInfo.statName,'_',myInfo.suffix,'.cbin');
    tic;
    myFid = write_header(myInfo,fileName);
    fprintf('Time to write header: %d\n',toc);
elseif initIRIG < 0
    %% Continuous code
    set(mainLabel,'String',datestr(currTime,'HH:MM:SS'));
    currTime = addtodate(currTime,1,'second'); %% time after samples acquired
    
    if myInfo.plotLive
        if fig1Index ~= 0
            addpoints(aline1,x,chanData(fig1Index,1:10000));
        else
            addpoints(aline1,x,irigData(1,1:10000));
        end
        if fig2Index ~= 0
            addpoints(aline2,x,chanData(fig2Index,1:10000));
        else
            addpoints(aline2,x,irigData(1,1:10000));
        end
        drawnow;
        x = x + 10000;
    end
    
    if IRIGsampTime~=0
        irigData = irigData * (2^myInfo.cardResolution) / 20;
        chanData = chanData * (2^myInfo.cardResolution) / 20;
        irigData = round(irigData);
        chanData = round(chanData);
        if IRIGsampTime > 0
            IRIGsampTime = IRIGsampTime - 1;
        end
        fwrite(myFid,[irigData;chanData],'int16');
        if IRIGsampTime == 0
            fwrite(myFid,hex2dec('7FFF'),'int16');
            fprintf('IRIG Done!\n');
            if myInfo.saveType == 2
                fileMemory = fileMemory - 2 * sampR * myInfo.IRIGtime;
            end
        end
    else
        chanData = chanData * (2^myInfo.cardResolution) / 20;
        chanData = round(chanData);
        fwrite(myFid,chanData,'int16');
    end
    
    if myInfo.saveType == 2 || myInfo.saveType == 3
        fileMemory =  fileMemory - 2 * sampR * size(chanData,1);
        fprintf('Bytes left: %d\n',fileMemory);
    else
        fileTime = fileTime - 1;
        fprintf('Seconds left: %d\n',fileTime);
    end
    if fileMemory <= 0 || fileTime == 0
        fileMemory = myInfo.saveMemory;
        fileTime = myInfo.saveTime;
        IRIGsampTime = myInfo.IRIGtime;
        fclose(myFid);
        fileName = strcat(myInfo.pn,'\',datestr(currTime,'yyyymmdd_HHMMSS_'),myInfo.statName,'_',myInfo.suffix,'.cbin');
        myFid = write_header(myInfo,fileName);
        fprintf('File saved\n');
    end
end
