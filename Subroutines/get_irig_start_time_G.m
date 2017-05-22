function time = get_irig_start_timeG(irig,fs,IRIG_type)


%input: 'irig' vector containing AT LEAST 1.1 sec (if IRIG-B) or 0.110 sec (if IRIG-A) of IRIG timecode
%input: fs= sampling frequency gotten from file header
%input: IRIG_type= IRIG type gotten from file header
%
%output: time=[doy hr mn sec] at precisely the first sample in the irig  vector
%
%last updated: 20 September 2007 by nj
%
%current capabilities:
%works IRIG B (mod and unmod), IRIG A (only unmod so far)
%careful about modulated/unmodulated
%current algorithm needs slightly more than exactly one irig period

%______________
%adjustable parameters
hithresh=0.7; %fraction of maximum signal required for a high level
zerothresh=0.5; %fraction of maximum signal required for a zero in mod irig
%________________

%________________
%first estimate sampling frequency and confirm OK
%check a short signal spectrum, make sure ok
%give a warning if not
%________________

%________________
%compute approximate samples per frame---not integers yet
%differentiate between IRIG-A and IRIG-B
[IRIG_type_AB]=regexp(IRIG_type, 'IRIG-[AB]','match'); %use 'regexp' to find IRIG type
if isequal(char(IRIG_type_AB),'IRIG-A')
    samp_per_frame=fs*1e-3; %1 ms frame
elseif isequal(char(IRIG_type_AB),'IRIG-B')
    samp_per_frame=fs*10e-3; %10 ms frame
end
%_________________


%determine if IRIG is unmodulated (<=>digital)
%if it is, set mod=0 otherwise set mod=1
[IRIG_type_unmod]=regexp(IRIG_type, 'digital','match'); %use 'regexp' to find IRIG digital type
if ~isempty(IRIG_type_unmod) %IRIG unmodulated detected
    mod=0;
else
    mod=1; %IRIG modulated detected
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        IRIG_A selected    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%if IRIG-A then take into the fact that one frame is coded on 1ms
if isequal(char(IRIG_type_AB),'IRIG-A')

    if mod==0 %IRIG-A digital selected
        irigabs=abs(irig-mean(irig));
        irig_hi=max(irigabs);
        %find all samples that register high in first two frames
        hisamps=find(irigabs(1:2*round(samp_per_frame))>hithresh*irig_hi);

        %if hisamps=1, set decoding_status to 'IRIG unreadable' and exit function
        if isempty(hisamps) | hisamps==1 %the IRIG signal is erroneous, do not continue decoding

            decoding_status='IRIG unreadable';

            
        else %the IRIG signal looks ok, continue decoding

            decoding_status='ok';

            %find first significant gap between high samples---gap must be at least 0.2 ms

            if irigabs(1) < hisamps(1) %test if first sample of timecode is < to first hisamps
                first_high=hisamps(1)-1;
            else
                first_high=min(hisamps(find(diff(hisamps)>round(0.2*0.001*fs))+1))-1;
            end

            first_edge_samp=first_high;
            start_frame=first_edge_samp;

            %if start_frame is empty, set decoding_status to 'IRIG unreadable' and exit function
            if isempty(start_frame) %the IRIG signal is erroneous, do not continue decoding

                decoding_status='IRIG unreadable';

            else

                for fi=1:108,
                    start_frame_vec(fi)=start_frame;
                    %find next frame edge
                    %find all samples that register high in next 1.1 frames
                    hisamps=find(irigabs(start_frame+(1:round(1.1*samp_per_frame)))>hithresh*irig_hi); %"1.1" works fine because it doesn't overshoot the matrix dimension and allow to include the next start_edge_samp

                    %find next significant gap between high samples and where the gap starts
                    [gap_btw_hisamps,start_gap_indice] = max(diff(hisamps));

                    %Determine the indice of the next frame edge
                    next_edge_samp=start_frame+start_gap_indice+gap_btw_hisamps-1;

                    %         if irigabs(next_edge_samp)>zerothresh*irig_hi,
                    %            disp('WARNING: problems finding subsequent frame edge');
                    %         end;

                    %now we have a complete frame from start_frame:next_edge_samp
                    %find the transition point from hi to lo and decode to 0, 1 or 2
                    frame_data=irigabs(start_frame:next_edge_samp);
                    if abs(length(frame_data)-samp_per_frame)/samp_per_frame>0.05,
                        disp('WARNING: frame length seems wrong');
                    end;

                    data_length=(length(frame_data) - gap_btw_hisamps)/samp_per_frame;
                    if data_length>0.15 & data_length<0.25,
                        irig_code(fi)=0;
                    elseif data_length>0.45 & data_length<0.58,
                        irig_code(fi)=1;
                    elseif data_length>0.75 & data_length<0.85,
                        irig_code(fi)=2;
                    else,
                        disp('WARNING: could not read irig frame data');
                    end;

                    %setup for next iteration
                    start_frame=next_edge_samp;

                    %When frame #100 reached, save "next_edge_samp" in order to
                    %calculate "fs_true" at the end of this program
                    if fi==100
                        hundred_frame_samp_index=next_edge_samp;
                    end

                end; %for

            end %end  if isempty(start_frame)


        end %end if hisamps==1
        
    
    elseif mod %IRIG_A modulated selected
        disp('IRIG-A decoding not implemented yet ! Sorry');
        decoding_status='IRIG unreadable';
        
    end %if mod or unmod IRIG-A

    
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        IRIG_B selected    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
%if IRIG-B then take into the fact that one frame is coded on 100ms
elseif isequal(char(IRIG_type_AB),'IRIG-B')

    if mod==0 %IRIG-B digital selected
        irigabs=abs(irig-mean(irig));
        irig_hi=max(irigabs);
        %find all samples that register high in first two frames
        hisamps=find(irigabs(1:2*round(samp_per_frame))>hithresh*irig_hi);

        %if hisamps=1, set decoding_status to 'IRIG unreadable' and exit function
        if isempty(hisamps) | hisamps==1 %the IRIG signal is erroneous, do not continue decoding

            decoding_status='IRIG unreadable';


        else %the IRIG signal looks ok, continue decoding

            decoding_status='ok';
            
            %find first significant gap between high samples---gap must be at least 2 ms
            first_high=min(hisamps(find(diff(hisamps)>round(2*0.001*fs))+1))-1;
            first_edge_samp=first_high;
            start_frame=first_edge_samp;

            %if start_frame is empty, set decoding_status to 'IRIG unreadable' and exit function
            if isempty(start_frame) %the IRIG signal is erroneous, do not continue decoding

                decoding_status='IRIG unreadable';

            else

                for fi=1:108,
                    start_frame_vec(fi)=start_frame;
                    %find next frame edge
                    %find all samples that register high in first two frames
                    hisamps=find(irigabs(start_frame +(1:round(1.1*samp_per_frame)))>hithresh*irig_hi); %"1.1" works fine because it doesn't overshoot the matrix dimension and allow to include the next start_edge_samp
                    %find next significant gap between high samples---gap must be three half
                    %   modulation periods
                    next_high=start_frame+min(hisamps(find(diff(hisamps)>round(2*0.001*fs))+1))-1;
                    %now find minimum sample in the previous half mod period
                    %this is the sample of the next frame edge
                    next_edge_samp=next_high;
                    %         if irigabs(next_edge_samp)>zerothresh*irig_hi,
                    %            disp('WARNING: problems finding subsequent frame edge');
                    %         end;
                    %now we have a complete frame from start_frame:next_edge_samp
                    %find the transition point from hi to lo and decode to 0, 1 or 2
                    frame_data=irigabs(start_frame:next_edge_samp);
                    if abs(length(frame_data)-samp_per_frame)/samp_per_frame>0.05,
                        disp('WARNING: frame length seems wrong');
                    end;
                    last_hi_samp=max(find(frame_data>hithresh*irig_hi));
                    data_length=last_hi_samp/samp_per_frame;
                    if data_length>0.15 & data_length<0.25,
                        irig_code(fi)=0;
                    elseif data_length>0.45 & data_length<0.58,
                        irig_code(fi)=1;
                    elseif data_length>0.75 & data_length<0.85,
                        irig_code(fi)=2;
                    else,
                        disp('WARNING: could not read irig frame data');
                    end;
                    %setup for next iteration
                    start_frame=next_edge_samp;

                    %When frame #100 reached, save "next_edge_samp" in order to
                    %calculate "fs_true" at the end of this program
                    if fi==100
                        hundred_frame_samp_index=next_edge_samp;
                    end

                end; %for


            end %end  if isempty(start_frame)

        end %end if hisamps==1
        
        
    elseif mod %IRIG_B modulated selected

        %set decoding_status to 'ok' for now by default
        decoding_status='ok';
        
        
        %remove DC and convert to abs
        irigabs=abs(irig-mean(irig));
        irig_hi=max(irigabs);
        %compute samples in a half modulation period
        half_mod_per=ceil(samp_per_frame/20); %10 periods per frame
        %_______________
        %find first full frame edge
        %find all samples that register high in first two frames
        hisamps=find(irigabs(1:2*round(samp_per_frame))>hithresh*irig_hi);
        %find first significant gap between high samples---gap must be three half
        %   modulation periods
        first_high=min(hisamps(find(diff(hisamps)>half_mod_per*3)+1));
        %now find minimum sample in the previous half mod period
        %this is the sample of the first frame edge
        [tmp,first_edge_samp]=min(irigabs((first_high-half_mod_per):first_high));
        first_edge_samp=first_edge_samp+(first_high-half_mod_per-1);
        if irigabs(first_edge_samp)>zerothresh*irig_hi,
            disp('WARNING: problems finding first frame edge');
        end;
        %_______________
        %now positioned at the start of the first frame
        %loop over 100 frames to get a full time code
        %general loop strategy: find the start of the NEXT frame
        %   then determine frame value based on magnitude of signal in frame
        start_frame=first_edge_samp;
        for fi=1:108,
            start_frame_vec(fi)=start_frame;
            %find next frame edge
            %find all samples that register high in first two frames
            hisamps=find(irigabs(start_frame+(1:round(1.1*samp_per_frame)))>hithresh*irig_hi); %"1.1" works fine because it doesn't overshoot the matrix dimension and allow to include the next start_edge_samp
            %find next significant gap between high samples---gap must be three half
            %   modulation periods
            next_high=start_frame+min(hisamps(find(diff(hisamps)>half_mod_per*3)+1));
            %now find minimum sample in the previous half mod period
            %this is the sample of the next frame edge
            [tmp,next_edge_samp]=min(irigabs((next_high-half_mod_per):next_high));
            next_edge_samp=next_edge_samp+(next_high-half_mod_per-1);
            if irigabs(next_edge_samp)>zerothresh*irig_hi,
               disp('WARNING: problems finding subsequent frame edge');
            end;
            %now we have a complete frame from start_frame:next_edge_samp
            %find the transition point from hi to lo and decode to 0, 1 or 2
            frame_data=irigabs(start_frame:next_edge_samp);
            if abs(length(frame_data)-samp_per_frame)/samp_per_frame>0.05,
                disp('WARNING: frame length seems wrong');
            end;
            last_hi_samp=max(find(frame_data>hithresh*irig_hi));
            data_length=(last_hi_samp+half_mod_per/4)/samp_per_frame;
            if data_length>0.15 & data_length<0.3, %.25
                irig_code(fi)=0;
            elseif data_length>0.45 & data_length<0.58,
                irig_code(fi)=1;
            elseif data_length>0.75 & data_length<0.9, %.85
                irig_code(fi)=2;
            else,
                disp('WARNING: could not read irig frame data');
            end;
            %setup for next iteration
            start_frame=next_edge_samp;
            
            %When frame #100 reached, save "next_edge_samp" in order to
            %calculate "fs_true" at the end of this program
            if fi==100
                hundred_frame_samp_index=next_edge_samp;
            end
            
            
        end; %for
        
    end %if mod or unmod IRIG-B
    
end %IRIG_A or IRIG_B




%__________________
%now if decoding_status 'ok, decode bit stream
%this is independent of A/B, mod/unmod

if isequal(decoding_status,'ok')

    %first find the 2/2 mark
    %handle special case of a 2 xxxxxx 2 data vector
    if irig_code(1)==2 & irig_code(100)==2,
        second_two_frame=1;
    else, %the twos should be consecutive
        twos=find(irig_code(1:100)==2); %!! Check in the first Hundred bits of IRIG_code only
        second_two_frame=twos(find(diff(twos)==1)+1);
    end;
    
    %if second_two_frame empty, there is a big chance that the
    %second_two_frame is at the index 101 of the irig_code
    %in that case, set it to 101 and continue
    if isempty(second_two_frame)
        second_two_frame=101;
    end
    
    timed_sample=start_frame_vec(second_two_frame);

    %establish wrapped decoding order
    bit_order=[second_two_frame:100 1:second_two_frame-1];
    if second_two_frame~=101
        bits=irig_code(bit_order(2:100)); %always skip the first 2 bit ???? first 1 bit???
    else
        bits=irig_code(bit_order(1:100)); %start from the first bit
    end
    first_part_of_bit_order=[second_two_frame+1:100]; %used later if timecode split
    first_part_bits=irig_code(first_part_of_bit_order); %used later if timecode split
    if bits(99)~=2 && second_two_frame~=101,disp('WARNING: error in bit ordering');end;


    %now compute time from bit stream
    %Note: Do not take "bit_remainders" into account right now. This will be
    %done when checking for eventual splits
    sec=bits(1)+2*bits(2)+4*bits(3)+8*bits(4);
    sec=sec+10*(bits(6)+2*bits(7)+4*bits(8));
    if isequal(char(IRIG_type_AB),'IRIG-A') %if IRIG-A, add ms information
        sec_copy=sec; %"sec_copy" does not take the ms into account and is used next whenever the ms are splitted
        sec=sec+(bits(45)+ 2*bits(46) + 4*bits(47) + 8*bits(48))*0.10; %take into account msec sent in the IRIG-A signal
    end
    mn=bits(10)+2*bits(11)+4*bits(12)+8*bits(13);
    mn=mn+10*(bits(15)+2*bits(16)+4*bits(17));
    hr=bits(20)+2*bits(21)+4*bits(22)+8*bits(23);
    hr=hr+10*(bits(25)+2*bits(26));
    doy=bits(30)+2*bits(31)+4*bits(32)+8*bits(33);
    doy=doy+10*(bits(35)+2*bits(36)+4*bits(37)+8*bits(38));
    doy_copy=doy; %'doy_copy does not take the hundred days into account and is used whenever the hundred are splitted
    doy=doy+100*(bits(40)+2*bits(41));



    %now sort out what adjustments must be made due to wrapping
    %if sections fully follow the reference bit, then they are correct
    %if sections fully precede the reference bit, then they need one second
    %   added
    %if sections are split by the wrap, then special care is needed
    %Differentiate between IRIG-A and IRIG-B
    if isequal(char(IRIG_type_AB),'IRIG-A') %IRIG-A selected
        if second_two_frame<52 %all 48 data bits data follows ref position and no corrections needed

            %take sec=0.00 and mn=0 into account
            if sec==0.00
                sec=60.0;
            end

            if sec==60.0 && mn==0
                mn==59;
                hr=hr-1;
                if hr<0
                    hr=23;
                    doy=doy-1;
                    if doy==0
                        disp('Day of Year maybe 365 or 366; please check manually');
                    end
                end

            elseif sec==60.0 && mn~=0
                mn=mn-1;
            end



        elseif second_two_frame>=52 & second_two_frame<=58
            %then 0.1sec split ; 0.1sec has to be recalculated
            %->Take "irig_code"
            %->Find the last bit '2'
            %->Decode from there using "sec_copy" (this variable does not
            %include the ms)
            %         disp('0.1 sec split');
            last_2_after_two_frame=find(first_part_bits==2,1,'last')+ second_two_frame; %last 2 after two frame index starting from bit 1 of 'IRIG code', NOT from 'bits'
            sec=sec_copy+(irig_code(last_2_after_two_frame+6)+ 2*irig_code(last_2_after_two_frame+7) + 4*irig_code(last_2_after_two_frame+8) + 8*irig_code(last_2_after_two_frame+9))*0.1;

            %take sec=0.00 and mn=0 into account
            if sec==0.00
                sec=60.0;
            end

            if sec==60.0 && mn==0
                mn==59;
                hr=hr-1;
                if hr<0
                    hr=23;
                    doy=doy-1;
                    if doy==0
                        disp('Day of Year maybe 365 or 366; please check manually');
                    end
                end

            elseif sec==60.0 && mn~=0
                mn=mn-1;
            end



        elseif second_two_frame>=59 & second_two_frame<=61
            %then "hundreds" of DOY and 0.1sec splitted; 'hundreds" of DOY have
            %to be recalculated
            %->Take "irig_code"
            %->Find the last bit '2'
            %->Decode new "hundreds" of DOY from there
            %->0.1 sec is totally splitted-> Add 0.1sec to 'sec'
            %         disp('"Hundreds" of DOY and 0.1 sec split');
            last_2_after_two_frame=find(first_part_bits==2,1,'last')+ second_two_frame; %last 2 after two frame index starting from bit 1 of 'IRIG code', NOT from 'bits'
            doy=doy_copy+100*(irig_code(last_2_after_two_frame+1)+ 2*irig_code(last_2_after_two_frame+2));

            %if nb of ms = 900, then number of seconds is correct, no need to
            %add 0.1sec to it; set it to sec_copy
            if (bits(45)+ 2*bits(46) + 4*bits(47) + 8*bits(48))*0.10 == 0.9
                sec=sec_copy;
            else
                sec=sec+0.1;
            end


            %take sec=0.00 and mn=0 into account
            if sec==0.00
                sec=60.0;
            end

            if sec==60.0 && mn==0
                mn==59;
                hr=hr-1;
                if hr<0
                    hr=23;
                    doy=doy-1;
                    if doy==0
                        disp('Day of Year maybe 365 or 366; please check manually');
                    end
                end

            elseif sec==60.0 && mn~=0
                mn=mn-1;
            end


        elseif second_two_frame>=62 & second_two_frame<71, %!!! note: if second_to_frame=70, there is not enough bits to read the DOY correctly..DOY will be deduce by wrapping..this may cause errors sometimes
            %then first part (NOT the 'hundreds')of DOY and 0.1 sec are split; first part of DOY
            %has to be recalculated
            %->Take "irig_code"
            %->Find the last bit '2'
            %->Decode new DOY from there
            %->0.1 sec is totally splitted-> Add 0.1sec to 'sec'
            %         disp('DOY and 0.1 sec split');
            last_2_after_two_frame=find(first_part_bits==2,1,'last')+ second_two_frame; %last 2 after two frame index starting from bit 1 of 'IRIG code', NOT from 'bits'
            doy=irig_code(last_2_after_two_frame+1)+ 2*irig_code(last_2_after_two_frame+2) + 4*irig_code(last_2_after_two_frame+3) + 8*irig_code(last_2_after_two_frame+4);
            doy=doy+10*(irig_code(last_2_after_two_frame+6)+ 2*irig_code(last_2_after_two_frame+7) + 4*irig_code(last_2_after_two_frame+8) + 8*irig_code(last_2_after_two_frame+9));
            doy=doy+100*(bits(40)+2*bits(41)); %add the "hundreds" to the previous number

            %if nb of ms = 900, then number of seconds is correct, no need to
            %add 0.1sec to it; set it to sec_copy
            if (bits(45)+ 2*bits(46) + 4*bits(47) + 8*bits(48))*0.10 == 0.9
                sec=sec_copy;
            else
                sec=sec+0.1;
            end


            %take sec=0.00 and mn=0 into account
            if sec==0.00
                sec=60.0;
            end

            if sec==60.0 && mn==0
                mn==59;
                hr=hr-1;
                if hr<0
                    hr=23;
                    doy=doy-1;
                    if doy==0
                        disp('Day of Year maybe 365 or 366; please check manually');
                    end
                end

            elseif sec==60.0 && mn~=0
                mn=mn-1;
            end



        elseif second_two_frame==71

            %if nb of ms = 900, then number of seconds is correct, no need to
            %add 0.1sec to it; set it to sec_copy
            if (bits(45)+ 2*bits(46) + 4*bits(47) + 8*bits(48))*0.10 == 0.9
                sec=sec_copy;
            else
                sec=sec+0.1;
            end


            %take sec=0.00 and mn=0 into account
            if sec==0.00
                sec=60.0;
            end

            if sec==60.0 && mn==0
                mn==59;
                hr=hr-1;
                if hr<0
                    hr=23;
                    doy=doy-1;
                    if doy==0
                        disp('Day of Year maybe 365 or 366; please check manually');
                    end
                end

            elseif sec==60.0 && mn~=0
                mn=mn-1;
            end



        elseif second_two_frame>=72 & second_two_frame<=81,
            %then hr DOY and 0.1 sec are split; hours has to be recalculated
            %->Take "irig_code"
            %->Find the last bit '2'
            %->Decode new hour from there
            %->0.1 sec is totally splitted-> Add 0.1sec to 'sec'
            %         disp('hr DOY and 0.1 sec split');
            last_2_after_two_frame=find(first_part_bits==2,1,'last')+ second_two_frame; %last 2 after two frame index starting from bit 1 of 'IRIG code', NOT from 'bits'
            hr=irig_code(last_2_after_two_frame+1)+ 2*irig_code(last_2_after_two_frame+2) + 4*irig_code(last_2_after_two_frame+3) + 8*irig_code(last_2_after_two_frame+4);
            hr=hr+10*(irig_code(last_2_after_two_frame+6)+ 2*irig_code(last_2_after_two_frame+7));

            %if nb of ms = 900, then number of seconds is correct, no need to
            %add 0.1sec to it; set it to sec_copy
            if (bits(45)+ 2*bits(46) + 4*bits(47) + 8*bits(48))*0.10 == 0.9
                sec=sec_copy;
            else
                sec=sec+0.1;
            end

            %take sec=0.00 and mn=0 into account
            if sec==0.00
                sec=60.0;
            end

            if sec==60.0 && mn==0
                mn==59;
                hr=hr-1;
                if hr<0
                    hr=23;
                    %NOTE that DAy of Year do not change here, it has already
                    %been taken into account in the wrapped decoding
                end

            elseif sec==60.0 && mn~=0
                mn=mn-1;
            end


        elseif second_two_frame>=82 & second_two_frame<=91,
            %then mn hr DOY and 0.1 sec are split; minutes have to be
            %recalculated
            %->Take "irig_code"
            %->Find the last bit '2'
            %->Decode new minutes from there
            %->0.1 sec is totally splitted-> Add 0.1 sec to 'sec'
            %         disp('mn hr DOY and 0.1 sec split');
            last_2_after_two_frame=find(first_part_bits==2,1,'last')+ second_two_frame; %last 2 after two frame index starting from bit 1 of 'IRIG code', NOT from 'bits'
            mn=irig_code(last_2_after_two_frame+1)+ 2*irig_code(last_2_after_two_frame+2) + 4*irig_code(last_2_after_two_frame+3) + 8*irig_code(last_2_after_two_frame+4);
            mn=mn+10*(irig_code(last_2_after_two_frame+6)+ 2*irig_code(last_2_after_two_frame+7)+ 4*irig_code(last_2_after_two_frame+8));

            %if nb of ms = 900, then number of seconds is correct, no need to
            %add 0.1sec to it; set it to sec_copy
            if (bits(45)+ 2*bits(46) + 4*bits(47) + 8*bits(48))*0.10 == 0.9
                sec=sec_copy;
            else
                sec=sec+0.1;
            end

            %take sec=0.00 into account
            if sec==0.00
                sec=60.0;
            end

            if sec==60.0 && mn==0
                mn==59;
                %NOTE!! Hours and DOY do not change here, they are already taken into
                %account in the wrapped decoding
            elseif sec==60.0 && mn~=0
                mn=mn-1;
            end


        elseif second_two_frame>=92 & second_two_frame<=99,
            %then sec mn hr DOY and 0.1 sec are split; seconds have to be
            %recalculated
            %->Take "irig_code"
            %->Find the last bit '2'
            %->Decode new seconds from there
            %->0.1 sec is totally splitted-> Add 0.1 sec to 'sec'
            %         disp('sec mn hr DOY and 0.1 sec split');
            sec=irig_code(second_two_frame+1)+ 2*irig_code(second_two_frame+2) + 4*irig_code(second_two_frame+3) + 8*irig_code(second_two_frame+4);
            sec=sec+10*(irig_code(second_two_frame+6)+ 2*irig_code(second_two_frame+7)+ 4*irig_code(second_two_frame+8));
            sec_copy=sec; %update sec_copy with the number decoded without wrapping the bits

            %if nb of ms = 900, then number of seconds is correct, no need to
            %add 0.1sec to it; set it to sec_copy
            %else add (bits(45)+ 2*bits(46) + 4*bits(47) + 8*bits(48))*0.10 + 0.1
            if (bits(45)+ 2*bits(46) + 4*bits(47) + 8*bits(48))*0.10 == 0.9
                sec=sec_copy;
            else
                sec=sec+ (bits(45)+ 2*bits(46) + 4*bits(47) + 8*bits(48))*0.10 + 0.1;
            end

            %take sec=0.00 and mn=0 into account
            if sec==0.00
                sec=60.0;
            end



        elseif second_two_frame==100,
            %then all data precede ref position and time is 0.1 second
            %early->add 0.1 sec
            sec=sec+0.1;


        end








    elseif isequal(char(IRIG_type_AB),'IRIG-B') %IRIG-B selected
        if second_two_frame<52 || second_two_frame==71, %for second_two_frame =71,  see explanations below
            %then all 48 data bits data follows ref position and no corrections needed

            %take sec=0.00 and mn=0 into account
            if sec==0.00
                sec=60.0;
            end

            if sec==60.0 && mn==0
                mn==59;
                hr=hr-1;
                if hr<0
                    hr=23;
                    doy=doy-1;
                    if doy==0
                        disp('Day of Year maybe 365 or 366; please check manually');
                    end
                end

            elseif sec==60.0 && mn~=0
                mn=mn-1;
            end


        elseif second_two_frame>=59 & second_two_frame<=61,
            %then "hundreds" of DOY splitted; 'hundreds" of DOY have
            %to be recalculated
            %->Take "irig_code"
            %->Find the last bit '2'
            %->Decode new "hundreds" of DOY from there
            %         disp('"Hundreds" of DOY split');
            last_2_after_two_frame=find(first_part_bits==2,1,'last')+ second_two_frame; %last 2 after two frame index starting from bit 1 of 'IRIG code', NOT from 'bits'
            doy=doy_copy+100*(irig_code(last_2_after_two_frame+1)+ 2*irig_code(last_2_after_two_frame+2));

            %take sec=0.00 and mn=0 into account
            if sec==0.00
                sec=60.0;
            end

            if sec==60.0 && mn==0
                mn==59;
                hr=hr-1;
                if hr<0
                    hr=23;
                    doy=doy-1;
                    if doy==0
                        disp('Day of Year maybe 365 or 366; please check manually');
                    end
                end

            elseif sec==60.0 && mn~=0
                mn=mn-1;
            end





        elseif second_two_frame>=62 & second_two_frame<71,  %!!! note: if second_to_frame=70, there is not enough bits to read the DOY correctly..DOY will be dduce by wrapping..this may cause errors sometimes
            %then first part (NOT the 'hundreds')of DOY  split; first part of DOY
            %has to be recalculated
            %->Take "irig_code"
            %->Find the last bit '2'
            %->Decode new DOY from there
            %         disp('DOY split');
            last_2_after_two_frame=find(first_part_bits==2,1,'last')+ second_two_frame; %last 2 after two frame index starting from bit 1 of 'IRIG code', NOT from 'bits'
            doy=irig_code(last_2_after_two_frame+1)+ 2*irig_code(last_2_after_two_frame+2) + 4*irig_code(last_2_after_two_frame+3) + 8*irig_code(last_2_after_two_frame+4);
            doy=doy+10*(irig_code(last_2_after_two_frame+6)+ 2*irig_code(last_2_after_two_frame+7) + 4*irig_code(last_2_after_two_frame+8) + 8*irig_code(last_2_after_two_frame+9));
            doy=doy+100*(bits(40)+2*bits(41)); %add the "hundreds" to the previous number

            %take sec=0.00 and mn=0 into account
            if sec==0.00
                sec=60.0;
            end

            if sec==60.0 && mn==0
                mn==59;
                hr=hr-1;
                if hr<0
                    hr=23;
                    doy=doy-1;
                    if doy==0
                        disp('Day of Year maybe 365 or 366; please check manually');
                    end
                end

            elseif sec==60.0 && mn~=0
                mn=mn-1;
            end


        elseif second_two_frame>=72 & second_two_frame<=81,
            %then hr DOY are split; hours has to be recalculated
            %->Take "irig_code"
            %->Find the last bit '2'
            %->Decode new hour from there
            %         disp('hr DOY split');
            last_2_after_two_frame=find(first_part_bits==2,1,'last')+ second_two_frame; %last 2 after two frame index starting from bit 1 of 'IRIG code', NOT from 'bits'
            hr=irig_code(last_2_after_two_frame+1)+ 2*irig_code(last_2_after_two_frame+2) + 4*irig_code(last_2_after_two_frame+3) + 8*irig_code(last_2_after_two_frame+4);
            hr=hr+10*(irig_code(last_2_after_two_frame+6)+ 2*irig_code(last_2_after_two_frame+7));

            %take sec=0.00 and mn=0 into account
            if sec==0.00
                sec=60.0;
            end

            if sec==60.0 && mn==0
                mn==59;
                hr=hr-1;
                if hr<0
                    hr=23;
                    %NOTE that DAy of Year do not change here, it has already
                    %been taken into account in the wrapped decoding
                end

            elseif sec==60.0 && mn~=0
                mn=mn-1;
            end



        elseif second_two_frame>=82 & second_two_frame<=91,
            %then mn hr DOY are split; minutes have to be
            %recalculated
            %->Take "irig_code"
            %->Find the last bit '2'
            %->Decode new minutes from there
            %         disp('mn hr DOY split');
            last_2_after_two_frame=find(first_part_bits==2,1,'last')+ second_two_frame; %last 2 after two frame index starting from bit 1 of 'IRIG code', NOT from 'bits'
            mn=irig_code(last_2_after_two_frame+1)+ 2*irig_code(last_2_after_two_frame+2) + 4*irig_code(last_2_after_two_frame+3) + 8*irig_code(last_2_after_two_frame+4);
            mn=mn+10*(irig_code(last_2_after_two_frame+6)+ 2*irig_code(last_2_after_two_frame+7)+ 4*irig_code(last_2_after_two_frame+8));

            %take sec=0.00 and mn=0 into account
            if sec==0.00
                sec=60.0;
            end

            if sec==60.0 && mn==0
                mn==59;
                %NOTE!! Hours and DOY do not change here, they are already taken into
                %account in the wrapped decoding
            elseif sec==60.0 && mn~=0
                mn=mn-1;
            end


        elseif second_two_frame>=92 & second_two_frame<=99, %notes !! here, the case second_to_frame = 99 can be taken into account, because seconds being coded on 8 bits, there will always be 8 bits available
            %then sec mn hr DOY are split; seconds have to be
            %recalculated
            %->Take "irig_code"
            %->Find the last bit '2'
            %->Decode new seconds from there
            %         disp('sec mn hr DOY split');
            sec=irig_code(second_two_frame+1)+ 2*irig_code(second_two_frame+2) + 4*irig_code(second_two_frame+3) + 8*irig_code(second_two_frame+4);
            sec=sec+10*(irig_code(second_two_frame+6)+ 2*irig_code(second_two_frame+7)+ 4*irig_code(second_two_frame+8));

            %take sec=0.00 into account
            if sec==0.00
                sec=60.0;
            end



        elseif second_two_frame==100,
            %then all data precede ref position and time is one second early
            sec=sec+1;

        end



    end


    %doy,hr,mins,sec is the time at sample timed_sample
    %need to extrapolate to first sample in the file
    %note that in modulated IRIG the frame length seems to drift around
    %so care is needed in this extrapolation
    %assume true sampling frequency is close to the number of samples in 100 frames
    fs_true=hundred_frame_samp_index-start_frame_vec(1);
    if isequal(char(IRIG_type_AB),'IRIG-A'),fs_true=fs_true*10;end;

    %subtract time equivalent of timed_sample to return to the start
    sec=sec-timed_sample/fs_true;


    %in case the number of sec is negative (second_two_frame==100 and nb of sec
    %= 0.000 at the first second two-frame), number of second = 60 + the
    %negative number of sec just calculated
    %Also adjust mns, hours and Day of Year
    if sec<0
        sec=60+sec;
        mn=mn-1;
        if mn<0
            mn=59;
            hr=hr-1;
            if hr<0
                hr=23;
                doy=doy-1;
                if doy==0
                    disp('Day of Year maybe 365 or 366; please check manually');
                end
            end
        end
    end


    %return time of first sample in the file
    time=[doy hr mn sec];


else %IRIG is erroneous

    %set time to N/A
    time='N/A';


end    % if isequal(decoding_status,'ok')


