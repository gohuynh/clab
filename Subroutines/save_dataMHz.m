function save_dataMHz(src,event)
%% Global variables
% global aline1; % animatedLine for fig1
% global aline2; % animatedLine for fig2
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
global uptimeLabel;
global scalingFactor;
global initIRIGConst;
global IRIGsampTimeConst;
global fig_one;
global fig_two;
global plotLive;
global fileName;
global errorFid;
global saveFid;
global errorLogName;
global saveLogName;
global showPlot;
global filesCreated;

%% Seperate data from daq
data = event.Data';
irigData = data(1,:);
chanData = data(2:end,:);
fprintf('DATA IN | ');
%% Find starting time
% Gather 2 seconds of IRIG to get initial time start
if initIRIG > 0
    initIRIGdata(sampR*(initIRIGConst+1-initIRIG)-sampR+1:sampR*(initIRIGConst+1-initIRIG)) = irigData;
    set(mainLabel,'String',['IRIG Second: ' num2str(initIRIG)]);
    initIRIG = initIRIG - 1;
end
if initIRIG == 0
    %% Calculate and store initial start time
    initTime = get_irig_start_time(initIRIGdata,sampR*scalingFactor,myInfo.IRIGtype);
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
    fprintf(saveFid, ['File begin: ', datestr(datetime('now')), '\n'], 'char');
    myFid = write_header(myInfo,fileName);
    filesCreated = filesCreated + 1;
    fileInfo = dir(fileName);
    fprintf(saveFid, 'aBytes: %d\n', fileInfo.bytes);
elseif initIRIG < 0
    %% Continuous code
    % logistics done at the beginning of every loop
    set(mainLabel,'String',datestr(currTime,'HH:MM:SS'));
    timeElapsed = round(datevec(currTime - timeStart));
    set(uptimeLabel, 'String', sprintf('Files Created: %d (%dd %dh %dm %ds)', filesCreated, timeElapsed(3:end)));
    currTime = addtodate(currTime,1000/scalingFactor,'millisecond'); %% time after samples acquired
    fprintf(saveFid, ['   DATA IN: ', datestr(datetime('now'), 'HH:MM:SS:FFF'), ' | '], 'char');
    
    %% Manages the plots
    if plotLive && showPlot
        if fig1Index ~= 0
            delete(fig_one.Children);
            plot(fig_one,x,chanData(fig1Index,1:sampR),'color','b');
        else
            delete(fig_one.Children);
            plot(fig_one,x,irigData(1,1:sampR),'color','b');
        end
        if fig2Index ~= 0
            delete(fig_two.Children);
            plot(fig_two,x,chanData(fig2Index,1:sampR),'color','r');
        else
            delete(fig_two.Children);
            plot(fig_two,x,irigData(1,1:sampR),'color','r');
        end
    elseif showPlot == 0 && (~isempty(fig_one.Children) || ~isempty(fig_two.Children))
        delete(fig_one.Children);
        delete(fig_two.Children);
    end
    
    %% For new files that need IRIG
    if IRIGsampTime~=0
        irigData = irigData * (2^myInfo.cardResolution) / 20;
        chanData = chanData * (2^myInfo.cardResolution) / 20;
        irigData = round(irigData);
        chanData = round(chanData);
        
        if IRIGsampTime > 0
            IRIGsampTime = IRIGsampTime - 1;
        end
        
        % Write data to file and logging
        writes = fwrite(myFid,[irigData;chanData],'int16');
        expectedWrites = sampR + size(chanData,1)*sampR;
        if(writes ~= sampR + size(chanData,1)*sampR)
            errormsg = ['Error in writing IRIG ', datestr(datetime('now')), '\n'];
            fprintf(errormsg);
            fprintf(errorFid, errormsg,'char');
        else
            savemsg = ['IRIG + data saved: ', datestr(datetime('now'), 'HH:MM:SS:FFF'), '\n'];
            fprintf(saveFid, savemsg,'char');
        end
        
        % Enough IRIG saved
        if IRIGsampTime == 0
            fwrite(myFid,hex2dec('7FFF'),'int16');
            fprintf('IRIG Done! | ');
            if myInfo.saveType == 2 || myInfo.saveType == 3
                fileMemory = fileMemory - 2 * sampR * myInfo.IRIGtime;
            end
            expectedWrites = expectedWrites + 1;
            writes = writes + 1;
        end
        
        % Logging data
        fileInfo = dir(fileName);
        fprintf(saveFid, '      eWrites: %d | aWrites: %d | eBytes: %d | aBytes: %d\n',...
            expectedWrites, writes, 2*(expectedWrites), fileInfo.bytes);
    %% Regular data collection
    else
        chanData = chanData * (2^myInfo.cardResolution) / 20;
        chanData = round(chanData);
        
        % Write data to file and logging
        writes = fwrite(myFid,chanData,'int16');
        if(writes ~= size(chanData,1)*sampR)
            errormsg = ['Error in writing data ', datestr(datetime('now')), '\n'];
            fprintf(errormsg);
            fprintf(errorFid, errormsg,'char');
        else
            savemsg = ['Data saved: ', datestr(datetime('now'), 'HH:MM:SS:FFF'), '\n'];
            fprintf(saveFid, savemsg, 'char');
        end
        
        % Data logging
        fileInfo = dir(fileName);
        fprintf(saveFid, '      eWrites: %d | aWrites: %d | eBytes: %d | aBytes: %d\n',...
                size(chanData,1)*sampR, writes, 2*(size(chanData,1)*sampR), fileInfo.bytes);
    end
    
    %% File management
    if myInfo.saveType == 2 || myInfo.saveType == 3
        fileMemory =  fileMemory - 2 * sampR * size(chanData,1);
        fprintf('Bytes left: %d\n',fileMemory);
    else
        fileTime = fileTime - 1/scalingFactor;
        fprintf('Seconds left: %d\n',fileTime);
    end
    
    % File full so begin new
    if fileMemory <= 0 || round(fileTime,2) == 0
        fileMemory = myInfo.saveMemory;
        fileTime = myInfo.saveTime;
        IRIGsampTime = IRIGsampTimeConst;
        if fclose(myFid) == 0
            savemsg = ['File saved: ', datestr(datetime('now')), '\n'];
            fprintf(saveFid, savemsg, 'char');
        else
            errormsg = ['Error closing file: ', datestr(datetime('now')), '\n'];
            fprintf(errorFid, errormsg, 'char');
        end
        fileName = strcat(myInfo.pn,'\',datestr(currTime,'yyyymmdd_HHMMSS_'),myInfo.statName,'_',myInfo.suffix,'.cbin');
        fprintf(saveFid, ['File begin: ', datestr(datetime('now')), '\n'], 'char');
        myFid = write_header(myInfo,fileName);
        filesCreated = filesCreated + 1;
        fprintf(saveFid, 'File bytes: %d\n', fileInfo.bytes);
        fprintf('File saved\n');
    end
    
    %% Log management
    fileInfo = dir(saveLogName);
    if fileInfo.bytes > 10000000
        fclose(errorFid);
        fclose(saveFid);
        errorFileInfo = dir(errorLogName);
        saveFileInfo = dir(saveLogName);
        if errorFileInfo.bytes == 0
            delete(errorLogName);
        end
        errorLogName = ['Logs/error_log_', datestr(datetime('now'),'yyyymmdd_HHMMSS'), '.txt'];
        saveLogName = ['Logs/save_log_', datestr(datetime('now'),'yyyymmdd_HHMMSS'), '.txt'];
        errorFid = fopen(errorLogName, 'wt');
        saveFid = fopen(saveLogName, 'wt');
    end
    
end
