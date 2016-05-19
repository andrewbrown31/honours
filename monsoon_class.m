function [low_lvl_uMean,dailyU_mean] = monsoon_class(low_layer,U)
%This function analyses the radiosonde data downloaded in netcdf form from
%the NOAA/ESRL radiosonde database (http://esrl.noaa.gov/raobs/). Twice
%daily radiosondes (00z and 12z) are taken at Darwin for the period
%01/11/2014 - 31/04/2015. The function then organises days into westerly
%monsoon periods based on Drosdowsky (1996) - which also requires a U input
%(which helps define the threshold for a westerly wind monsoonal anomaly.
%Note that 300-100hPa winds need to be Easterly to be considered monsoonal.
%INPUT:
%Low layer defines the layer in which zonal wind component is considered
%(in hPa). U appears in the monsoon wind threshold (defines how strong the
%westerly wind needs to be to consider is a monsoon period).
%OUTPUT
%Function plots the daily mean wind speed averaged over the low layer
%(unweighted). Also shades the days which are defined as active monsoon
%wind bursts.

%Note with Low level 850 to 700 and U = 3, Active periods are from Jan 1 to
%Jan 24 and Feb 21 to Feb 24

%Read in netCDF radiosonde file
[~,rsStruct] = read_nc_file_struct('F:\working\radsonde\raob_soundings31132.cdf');
%Find indices where pressure is below the low layer, and data points exist
[r,c] = find(rsStruct.prMan == low_layer & rsStruct.prMan < 2000 ...
                & rsStruct.wsMan < 1000 & rsStruct.wdMan <= 360);
%Replace all unphysical data points with NaN
rsStruct.wsMan(rsStruct.wsMan==9.9692100e+36)=NaN;
rsStruct.wsMan(rsStruct.wdMan==9.9692100e+36)=NaN;

%Initialise low level wind fields
low_lvl_u = NaN(max(r),max(c));
low_lvl_v = NaN(max(r),max(c));

%Create arrays of v and u components for where data exists below the low
%level.
for i = 1:length(r)
        low_lvl_ws(r(i),c(i)) = rsStruct.wsMan(r(i),c(i));
        low_lvl_wd(r(i),c(i)) = rsStruct.wdMan(r(i),c(i));
        low_lvl_u(r(i),c(i)) = low_lvl_ws(r(i),c(i))*sind(low_lvl_wd(r(i),c(i)));
        low_lvl_v(r(i),c(i)) = low_lvl_ws(r(i),c(i))*cosd(low_lvl_wd(r(i),c(i)));
end

%Create arrays of v and u components for where data exists in the upper
%level (300-100hPa)
[r_up,c_up] = find(rsStruct.prMan >= 100 & rsStruct.prMan < 300 ...
                & rsStruct.wsMan < 1000 & rsStruct.wdMan <= 360);

for i = 1:length(r_up)
        up_lvl_ws(r_up(i),c_up(i)) = rsStruct.wsMan(r_up(i),c_up(i));
        up_lvl_wd(r_up(i),c_up(i)) = rsStruct.wdMan(r_up(i),c_up(i));
        up_lvl_u(r_up(i),c_up(i)) = up_lvl_ws(r_up(i),c_up(i))*sind(up_lvl_wd(r_up(i),c_up(i)));
        up_lvl_v(r_up(i),c_up(i)) = up_lvl_ws(r_up(i),c_up(i))*cosd(up_lvl_wd(r_up(i),c_up(i)));
end            

%Take the mean of the u component below the low layer for each sounding.
[~,sounds] = size(low_lvl_u);
for i = 1:sounds
    low_lvl_uMean(i) = nanmean(low_lvl_u(:,i));
    up_lvl_uMean(i) = nanmean(up_lvl_u((9:12),i));
end

%Create an array of times corresponding to each sounding, in local time
%strings and utc numbers. Original data is in seconds after 01/01/1970.
for i = 1:sounds
    if rsStruct.synTime(i) < 9e35
        times(i) = (rsStruct.synTime(i))./(60*60*24) + datenum([1970 01 01 00 00 00]);
        times_LT(i) = times(i) + (9.5/24); 
        timesStr_LT{i} = datestr(times_LT(i));
    else
        times(i) = NaN;
        timesStr_LT{i} = 'None';
    end
end

%Composite the soundings (twice daily) into a daily mean.
count = 1;
for i = 2:2:(sounds-1)
    dailyU_mean(count) = -mean([low_lvl_uMean(i),low_lvl_uMean(i-1)]);
    dailyU_upMean(count) = -mean([up_lvl_uMean(i),up_lvl_uMean(i-1)]);
    daily_times(count) = times(i);
    count = count + 1;
end

%Determine wheteher the daily mean meets the requirements of an active
%westerly monsoon (Drosdowsky 1996)
wind_thresh_n = zeros(1,length(dailyU_mean));
wind_thresh = zeros(1,length(dailyU_mean));
westerly = zeros(1,length(dailyU_mean));
Break = zeros(1,length(dailyU_mean));
transition = zeros(1,length(dailyU_mean));
Sum = zeros(1,length(dailyU_mean));
average = zeros(1,length(dailyU_mean));

for i = 1:length(dailyU_mean)
    if dailyU_mean(i) > 0
        count = 1;
        wind_thresh_n(i) = 1;
        Sum(i) = Sum(i) + dailyU_mean(i);
        if (i+count) < length(dailyU_mean)
            while dailyU_mean(i+count) > 0 && (i+count) < length(dailyU_mean)
                Sum(i) = Sum(i) + dailyU_mean(i+count);
                count = count+1;
                wind_thresh_n(i) = wind_thresh_n(i)+1;  
            end
        end
        count = 1;
        if (i-count) > 0
            while dailyU_mean(i-count) > 0
                Sum(i) = Sum(i) + dailyU_mean(i-count);
                count = count+1;
                wind_thresh_n(i) = wind_thresh_n(i)+1;
               
                if (i-count) == 0
                    break 
                end
            end
        end
    end
    average(i) = Sum(i)/wind_thresh_n(i);
    %wind_thresh(i) = (U.*(wind_thresh_n(i)+1))./wind_thresh_n(i);
    if abs(average(i)) > (U*(wind_thresh_n(i)+1))/wind_thresh_n(i)...
            && dailyU_upMean(i) < 0;
        westerly(i) = 1;
    end
    if dailyU_upMean(i) < 0 && westerly(i) ~= 1
        Break(i) = 1;
    end
    if Break(i) ~= 1 && westerly(i) ~= 1 
        transition(i) = 1;
    end
end

%Plot the daily mean, with shading representing the days defined as active
%westerly monsoon periods
westerly_pos = westerly*24.8;
westerly_neg = westerly*-24.8;
break_pos = Break*24.8;
break_neg = Break*-24.8;
transition_pos = transition*24.8;
transition_neg = transition*-24.8;
c_w = [.9,.9,.9];
c_b = [.75,.75,.75];
c_t = [.95,.95,.95];
bar(daily_times,westerly_pos,'FaceColor',c_w,'EdgeColor',c_w)
hold on
bar(daily_times,westerly_neg,'FaceColor',c_w,'EdgeColor',c_w)
bar(daily_times,break_pos,'FaceColor',c_b,'EdgeColor',c_b)
bar(daily_times,break_neg,'FaceColor',c_b,'EdgeColor',c_b)
% bar(daily_times,transition_pos,'FaceColor',c_t,'EdgeColor',c_t)
% bar(daily_times,transition_neg,'FaceColor',c_t,'EdgeColor',c_t)
h1 = plot(daily_times,dailyU_mean);
h2 = plot(daily_times,dailyU_upMean);
legend([h1,h2],'Low Level u','Upper Level u')
datetick(gca)
title('Active monsoon bursts, 2014/2015')
ylabel('U component (m/s)')
%Figure caption: Plot of daily average low level u wind component (from
%surface to U, probably 500hPa) and daily average upper level u wind
%component (100-300hPa) in m/s. From Darwin radiosonde downloaded from esrl
%noaa period Nov 2014-Apr 2015. Active westerly monsoon regimes (shaded) definened 
%as in Drosdowsky (1996).
end