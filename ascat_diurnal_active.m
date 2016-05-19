function [ascat_struct_active,comp_mean_U_active,comp_mean_V_active,comp_count_active]...
    = ascat_diurnal_active(diurnal_bins)
%This function runs ascat_avg2 daily for active monsoon periods (January
%and Feb 21-24), with the day split into time bins, the amount of which is
%specified by diurnal_bins. The function then averages wind vectors over
%the time period of the function, into the daily bins. The function also
%sums the data count for each daily bin for the whole period
%
%INPUT: diurnal_bins is an integer corresponding to the amount of time bins
%per day (starting from 00:00). Extras contains info about the spatial
%binning for input into ascat_avg

%OUTPUT: ascat_struct is a structure containing wind vector grids for each
%day, split up into time bins. comp_mean_U and comp_mean_V are cells
%containing mean u and v wind components composited over the whole time
%period. Each column in the cell is a time bin. comp_count is a count of
%data points over the start/end_time period, again for each time bin.

cnt = 1;

extras = ascat_extras;
start_time1 = datenum([2015 01 01 23 30 00]);
end_time1 = datenum([2015 02 01 23 30 00]);
start_time2 = datenum([2015 02 21 23 30 00]);
end_time2 = datenum([2015 02 24 23 30 00]);
current_num = start_time1;

end_cnt = etime(datevec(end_time2),datevec(start_time1))/(60*60*25);
h = waitbar(0,'Compositing and Binning Diurnal Wind');
while current_num <= end_time2
    if ~(current_num > end_time1 && current_num < start_time2)  
        waitbar(cnt/end_cnt)
        end_day = current_num + 1;
        str = ['d' datestr(current_num,'yymmdd')];
        [ascat_struct_active.mean_U.(str),ascat_struct_active.mean_V.(str),ascat_struct_active.count.(str)] = ...
        ascat_avg2(datevec(current_num),datevec(end_day),diurnal_bins,extras);
        for i = 1:diurnal_bins
                diurnal_struct_active.(str) = ascat_struct_active;
                diurnal_mean_U{i}(:,:,cnt) = ascat_struct_active.mean_U.(str){i};
                diurnal_mean_V{i}(:,:,cnt) = ascat_struct_active.mean_V.(str){i};
                diurnal_count{i}(:,:,cnt) = ascat_struct_active.count.(str)(:,:,i)-1;
        end
        cnt = cnt+1;
    end
        current_num = current_num + 1;
end
for i = 1:length(diurnal_mean_U)
    comp_mean_U_active{i} = mean(diurnal_mean_U{i},3,'omitnan');
    comp_mean_V_active{i} = mean(diurnal_mean_V{i},3,'omitnan');
    comp_count_active{i} = sum(diurnal_count{i},3,'omitnan');
end
close(h)
end