function [sum] = add_seconds(original_time, seconds_to_add)
%% Update Seconds
temp_sec = original_time(6) + seconds_to_add;
if temp_sec >= 60
    addMinute = floor(temp_sec / 60);
    temp_sec = mod(temp_sec, 60);
else
    addMinute = 0;
end

%% Update Minutes
temp_min = original_time(5);
if addMinute ~= 0
    temp_min = temp_min + addMinute;
end
if temp_min > 60
    addHour = floor(temp_min / 60);
    temp_min = mod(temp_min, 60);
else
    addHour = 0;
end

%% Update Hours
temp_hr = original_time(4);
if addHour ~= 0
    temp_hr = temp_hr + addHour;
end
if temp_hr > 24
    addDay = floor(temp_hr / 24);
    temp_hr = mod(temp_hr, 24);
else
    addDay = 0;
end

%% Update Date
temp_date = [original_time(1:3) 0 0 0];
if addDay ~= 0
    temp_date = datevec(addtodate(datenum(temp_date),addDay,'day'));
end

%% Final Output

sum = [temp_date(1:3) temp_hr temp_min temp_sec];

end

