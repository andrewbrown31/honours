function [comp,ascat_struct,extras] = ...
    ascat_diurnal(active_only,active_flag,diurnal_bins,start_time,end_time)
%This function runs ascat_avg2 daily from start_time to end_time, with the
%day split into time bins, the amount of which is specified by diurnal_bins.
%The function then composites the diurnal bins for the time period. 
%The function also sums the data count for each diurnal bin for the whole
%period for assessment of coverage. It also can compute perturbation wind
%fields, also in diurnal bins. This is done by first getting a 7-day
%running average wind for each spatial point, before subtracting this from
%the actual wind speed.
%Coutputs with diurnal bins (as cells) can be plotted using
%plot_ascat_diurnal.

%INPUT: start_time and end_time in date vector form. diurnal_bins is an
%integer corresponding to the amount of time bins within a day from
%the hour in the start_time vector. active_flag specifies whether the average
%excludes active periods (1 = include January 1-24 and Feb 21-24). 
%Extras contains info about the spatial binning for input into ascat_avg
%amongst other flags and settings. Active_only makes the time period equal
%to defined active periods (Jan 1-24 Feb 21-24). Note if active_only is on
%then active_flag doesn't matter

%OUTPUT: ascat_struct is a structure containing wind vector grids for each
%day, split up into time bins. comp.mean_U and comp.mean_V are cells
%containing mean u and v wind components composited over the whole time
%period. Each column in the cell is a time bin. comp.count is a count of
%data points over the start/end_time period, again for each time bin.

%NOTE THAT HAVING ACTIVE PERIOD SPLIT INTO TWO SUB-PERIODS WILL NOT PRODUCE
%THE RIGHT RUNNING AVERAGE IN THE CURRENT CONFIGURATION. FOR ACTIVE PERIOD
%CHOOSE INPUT (0,1,6,[2015 01 01 23 30],[2015 01 24 23 30 0]) I.E. IGNORE 4
%DAY SUB-PERIOD IN FEB.

%% DRIVE ASCAT_AVG2
% RUN ASCAT_AVG2 DAILY TO CREATE DIURNAL BINS. Version depends on
% active_only flag
if ~active_only
    extras = ascat_extras;
    extras.start_time = start_time;
    extras.end_time = end_time;
    current_num = datenum(start_time);
    end_num = datenum(end_time);
    cnt = 1;
    end_cnt = etime(end_time,start_time)/(60*60*25);
    active_start1 = datenum([2015 01 01 00 00 00]);
    active_end1 = datenum([2015 02 01 00 00 00]);
    active_start2 = datenum([2015 02 21 00 00 00]);
    active_end2 = datenum([2015 02 24 00 00 00]);

    h = waitbar(0,'Compositing and Binning Diurnal Wind');
    %Bin each day into diurnal bins
    while current_num <= end_num
            waitbar(cnt/end_cnt)
        if ((current_num < active_start1 || current_num > active_end1)...
                && (current_num < active_start2 || current_num > active_end2)) || active_flag
            end_day = current_num + 1;
            str{cnt} = ['d' datestr(current_num,'yymmdd')];
            [ascat_struct.mean_U.(str{cnt}),ascat_struct.mean_V.(str{cnt}),ascat_struct.count.(str{cnt}),...
                ascat_struct.U.(str{cnt}),ascat_struct.V.(str{cnt})] = ...
                ascat_avg2(datevec(current_num),datevec(end_day),diurnal_bins,extras);
            for i = 1:diurnal_bins
                    diurnal_mean_U{i}(:,:,cnt) = ascat_struct.mean_U.(str{cnt}){i};
                    diurnal_mean_V{i}(:,:,cnt) = ascat_struct.mean_V.(str{cnt}){i};
                    diurnal_count{i}(:,:,cnt) = ascat_struct.count.(str{cnt})(:,:,i)-1;
                    
                    ascat_struct.mean2_U = diurnal_mean_U;
                    ascat_struct.mean2_V = diurnal_mean_V;
            end
            cnt = cnt+1;
        end
        current_num = current_num + 1;
    end
end

if active_only
    cnt = 1;
    extras = ascat_extras;
    start_time1 = datenum([2015 01 01 23 30 00]);
    end_time1 = datenum([2015 01 24 23 30 00]);
    start_time2 = datenum([2015 02 21 23 30 00]);
    end_time2 = datenum([2015 02 24 23 30 00]);
    extras.start_time = [2015 01 01 23 30 00];
    extras.end_time = [2015 02 24 23 30 00];
    current_num = start_time1;

    end_cnt = etime(datevec(end_time2),datevec(start_time1))/(60*60*25);
    h = waitbar(0,'Compositing and Binning Diurnal Wind');
    while current_num <= end_time2
        if ~(current_num > end_time1 && current_num < start_time2)  
            waitbar(cnt/end_cnt)
            end_day = current_num + 1;
            str{cnt} = ['d' datestr(current_num,'yymmdd')];
            [ascat_struct.mean_U.(str{cnt}),ascat_struct.mean_V.(str{cnt}),ascat_struct.count.(str{cnt}),...
                ascat_struct.U.(str{cnt}),ascat_struct.V.(str{cnt})] = ...
            ascat_avg2(datevec(current_num),datevec(end_day),diurnal_bins,extras);
            for i = 1:diurnal_bins
                    diurnal_mean_U{i}(:,:,cnt) = ascat_struct.mean_U.(str{cnt}){i};
                    diurnal_mean_V{i}(:,:,cnt) = ascat_struct.mean_V.(str{cnt}){i};
                    diurnal_count{i}(:,:,cnt) = ascat_struct.count.(str{cnt})(:,:,i)-1;
            end
            cnt = cnt+1;
        end
            current_num = current_num + 1;
    end
end
close(h)

%Average each diurnal bin over the amount of days from start to end 
for i = 1:length(diurnal_mean_U)
    comp.mean_U{i} = nanmean(diurnal_mean_U{i},3);
    comp.mean_V{i} = nanmean(diurnal_mean_V{i},3);
    comp.count{i} = nansum(diurnal_count{i},3);
    
    %Throw out any composites which don't have many counts
    if extras.t_flag
        [k,j] = find(comp.count{i} <= max(max(comp.count{i}))*extras.t);
        for ii = 1:length(k)
            comp.mean_U{i}(k(ii),j(ii)) = NaN;
            comp.mean_V{i}(k(ii),j(ii)) = NaN;
        end
    end
end

[rows,cols,days] = size(diurnal_count{1});
%% AVERAGE/PERTURBATION Option 1
%Isolate perturbation wind by getting mean wind and subtracting from
%current wind. Mean wind given by averaging over 7 days around the time
%period, at each grid space.

%First, get running mean wind
if extras.avg_flag == 1
for i = 1:days                     %Loop over days
    %if (i - extras.day_avg >= 1) && (i + extras.day_avg <= days)    %If the running avg fits inside the period
        for j = 1:rows              %Loop over rows
            for k = 1:cols          %Loop over columns                 
                    for l = 1:diurnal_bins                    
                        %Put all diurnal bins for day i into the same
                        %matrix (4d)
                        mean_days_U(j,k,i,l) = diurnal_mean_U{l}(j,k,i);   
                        mean_days_V(j,k,i,l) = diurnal_mean_V{l}(j,k,i);                        
                    end
                    %Average along diurnal bin dimension to produce daily
                    %avg. Put daily averages running mean time in same
                    %dimension
                    daily_mean_U(j,k,i) = nanmean(mean_days_U(j,k,i,:),4);
                    daily_mean_V(j,k,i) = nanmean(mean_days_V(j,k,i,:),4); 
            end
        end
    %end
end

for i = 1+extras.day_avg:days-extras.day_avg
    for j = 1:rows
        for k = 1:cols
            running_mean_U(j,k,i) = nanmean(daily_mean_U(j,k,i-extras.day_avg:i+extras.day_avg));
            running_mean_V(j,k,i) = nanmean(daily_mean_V(j,k,i-extras.day_avg:i+extras.day_avg));
        end
    end
end

%Now get the perturbation wind
for i = 1+extras.day_avg:(days-extras.day_avg)
    for j = 1:rows
        for k = 1:cols
            for l = 1:diurnal_bins
                pert_U{l}(j,k,i-extras.day_avg) = diurnal_mean_U{l}(j,k,i) - running_mean_U(j,k,i);
                pert_V{l}(j,k,i-extras.day_avg) = diurnal_mean_V{l}(j,k,i) - running_mean_V(j,k,i);
            end
        end
    end
end

%Composite over the time period
for l = 1:diurnal_bins
    comp.pert_U{l}(:,:) = nanmean(pert_U{l},3);
    comp.pert_V{l}(:,:) = nanmean(pert_V{l},3);
    if extras.t_flag
        [k,j] = find(comp.count{l} <= max(max(comp.count{l}))*extras.t);
        for ii = 1:length(k)
            comp.pert_U{l}(k(ii),j(ii)) = NaN;
            comp.pert_V{l}(k(ii),j(ii)) = NaN;
    end
    end
end
end

%% AVERAGE/PERTURBATION Option 2
%Try a less conveluded background wind calculation with less averaging.
%Start with binned data that hasn't been averaged. Combine across diurnal
%bins.

if extras.avg_flag == 2
daily_total_U = cell(rows,cols,days);
daily_total_V = cell(rows,cols,days);
for i = 1:days
    for j = 1:rows
        for k = 1:cols
            for l = 1:diurnal_bins
                temp_U = ascat_struct.U.(str{i}){j,k,l};
                daily_total_U{j,k,i} = [daily_total_U{j,k,i} temp_U];
                temp_V = ascat_struct.V.(str{i}){j,k,l};
                daily_total_V{j,k,i} = [daily_total_V{j,k,i} temp_V];
                ascat_struct.daily_U(j,k,i) = nanmean(daily_total_U{j,k,i});
                ascat_struct.daily_V(j,k,i) = nanmean(daily_total_V{j,k,i});
            end
        end
    end 
end

%Now combine across the running mean period.
running_total_U = cell(rows,cols,days);
running_total_V = cell(rows,cols,days);
for i = 1+extras.day_avg:(days-extras.day_avg)
    for j = 1:rows
        for k = 1:cols
            for ii = -extras.day_avg:extras.day_avg
                temp_U = daily_total_U{j,k,i+ii};
                running_total_U{j,k,i} = [running_total_U{j,k,i} temp_U];
                temp_V = daily_total_V{j,k,i+ii};
                running_total_V{j,k,i} = [running_total_V{j,k,i} temp_V];
            end
        end
    end
end
%Now we have running totals (over the running mean period for each day) we
%can average.
running_mean2_U = zeros(rows,cols,days);
running_mean2_V = zeros(rows,cols,days);
for i = 1:days
    for j = 1:rows
        for k = 1:cols
            running_mean2_U(j,k,i) = nanmean(running_total_U{j,k,i});
            running_mean2_V(j,k,i) = nanmean(running_total_V{j,k,i});
        end
    end
end
%Now we have running means for each day. Get perturbation winds as before.
for i = 1+extras.day_avg:(days-extras.day_avg)
    for j = 1:rows
        for k = 1:cols
            for l = 1:diurnal_bins
                ascat_struct.pert_U{l}(j,k,i-extras.day_avg) = diurnal_mean_U{l}(j,k,i) - running_mean2_U(j,k,i);
                ascat_struct.pert_V{l}(j,k,i-extras.day_avg) = diurnal_mean_V{l}(j,k,i) - running_mean2_V(j,k,i);
            end
        end
    end
end
%And composite over time period.
for l = 1:diurnal_bins
    comp.pert_U{l}(:,:) = nanmean(ascat_struct.pert_U{l},3);
    comp.pert_V{l}(:,:) = nanmean(ascat_struct.pert_V{l},3);
    [k,j] = find(comp.count{l} <= max(max(comp.count{l}))*extras.t);
    for ii = 1:length(k)
        comp.pert_U{l}(k(ii),j(ii)) = NaN;
        comp.pert_V{l}(k(ii),j(ii)) = NaN;
    end
end
end
%% GET WIND SPEEDS FOR DIURNAL BINS
for l = 1:diurnal_bins
    comp.ws.mean{l} = ((comp.mean_U{l}.^2) + (comp.mean_V{l}.^2)).^(1/2);
    comp.ws.pert{l} = ((comp.pert_U{l}.^2) + (comp.pert_V{l}.^2)).^(1/2);
end

    comp.diff_U{1} = comp.mean_U{1} - comp.mean_U{4};
    comp.diff_U{4} = comp.mean_U{4} - comp.mean_U{1};
    comp.diff_V{1} = comp.mean_V{1} - comp.mean_V{4};
    comp.diff_V{4} = comp.mean_V{4} - comp.mean_V{1};


end