function myFid = write_header(psd_info,filename)
global errorFid;
global saveFid;
%% Format or retrieve session details
myFid = fopen(filename,'w','ieee-be');
aChannels = psd_info.aChannels;
softwareVersion = 'V5.2';
stationName = psd_info.statName;
channelLabels = {'IRIG' 'B1' 'B2' 'B3' 'B4' 'B5' 'B6' 'B7'};
activeChan = find(aChannels == 1);
channelNames = '';
for k = 1:length(activeChan)
    channelNames = [channelNames channelLabels{k} ' (Ch' num2str(activeChan(k)-1) ') + '];
end
channelNames = channelNames(1:(end-3));
IRIGtype = psd_info.IRIGtype;
clockType = 'External Scan Clock';
cardResolution = psd_info.cardResolution;
sensorRef = psd_info.sensRef;
% headerSize is total bytes used for header
% Sum of total hardcoded bytes(60) and 6 variable length bytes
headerSize = 60 + length(softwareVersion) + length(stationName) + length(channelNames)... 
             + length(IRIGtype) + length(clockType) + length(sensorRef);
totalWrites = 15 + length(softwareVersion) + length(stationName) + length(channelNames)...
              + length(IRIGtype) + length(clockType) + length(sensorRef);
%% Write header info
writes = 0;
writes = writes + fwrite(myFid,headerSize,'uint32');% Length of header (1 int) (DO NOT ADD IN TOTAL NUM OF BYTES)
writes = writes + fwrite(myFid,length(softwareVersion),'uint32');% Length of software version (1 int)(4 bytes)
writes = writes + fwrite(myFid,softwareVersion,'char');% Software Version (n char) (n bytes)
writes = writes + fwrite(myFid,length(stationName),'uint32');% Length of station name (1 int)(4 bytes)
writes = writes + fwrite(myFid,stationName,'char');% Station Name (n char) (n bytes)
writes = writes + fwrite(myFid,psd_info.latMag,'float64');% latitude (1 double) (8 bytes)
writes = writes + fwrite(myFid,psd_info.latDir,'char');% latitude direction (1 char) (1 bytes)
writes = writes + fwrite(myFid,psd_info.longMag,'float64');% longitude (1 double) (8 bytes)
writes = writes + fwrite(myFid,psd_info.longDir,'char');% longitude direction (1 char) (1 bytes)
writes = writes + fwrite(myFid,sum(aChannels),'uint32');% number of channels (1 int) (4 bytes)
writes = writes + fwrite(myFid,length(channelNames),'uint32');% Length of channel name (1 int) (4 bytes)
writes = writes + fwrite(myFid,channelNames,'char');% Channel Names (n char) (n bytes)
writes = writes + fwrite(myFid,length(IRIGtype),'uint32');% Length of IRIG type (1 int) (4 bytes)
writes = writes + fwrite(myFid,IRIGtype,'char');% IRIG type (n char) (n char)
writes = writes + fwrite(myFid,psd_info.IRIGtime,'uint16');% Amount of IRIG saved (1 int) (2 bytes)
writes = writes + fwrite(myFid,psd_info.sampRate,'uint32');% Sampling rate (1 int) (4 bytes)
writes = writes + fwrite(myFid,length(clockType),'uint32');% Length of clock type (1 int) (4 bytes)
writes = writes + fwrite(myFid,clockType,'char');% Clock type (n char) (n bytes)
writes = writes + fwrite(myFid,cardResolution,'float64');% Card resolution (1 double) (8 bytes)
writes = writes + fwrite(myFid,length(sensorRef),'uint32');% Length of sensor ref (1 int) (4 bytes)
writes = writes + fwrite(myFid,sensorRef,'char');% Sensor ref (n char) (n bytes)
if totalWrites ~= writes
    errormsg = ['Error in writing header ', datestr(datetime('now')), '\n'];
    fprintf(errormsg);
    fprintf(errorFid, errormsg,'char');
end
fprintf(saveFid, '      eWrites: %d | aWrites: %d | eBytes: %d ', totalWrites, writes, headerSize + 4);



