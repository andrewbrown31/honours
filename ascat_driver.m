function [comp,ascat_struct,extras] = ascat_driver
str = {'act','nac','bre','nov','dec','feb','mar','apr'};
start_time = {[2015 01 01 23 30 0],[2014 11 01 23 30 0],[2014 12 01 23 30 0],[2014 11 01 23 30 0],...
    [2014 12 01 23 30 0],[2015 02 01 23 30 0],[2015 03 01 23 30 0],[2015 04 01 23 30 0]};
end_time = {[2015 02 28 23 30 0],[2015 04 30 23 30 0],[2015 03 31 23 30 0],[2014 11 30 23 30 0],...
    [2014 12 31 23 30 0],[2015 02 28 23 30 0],[2015 03 31 23 30 0],[2015 04 30 23 30 0]};
diurnal_bins = 6;

for i = 1:length(str)
    ['binning,compositing and plotting ' str{i}]
    
    if i == 1
        active_only = 1;
        plot_active_only = 1;
    else
        active_only = 0;
    end
    
    if i == 6
        active_flag = 1;
    else
        active_flag = 0;
    end
    
    if i == 2 || i ==3 
        plot_active_only = 2;
    end
    
    [comp.(str{i}),ascat_struct.(str{i}),extras.(str{i})] = ...
        ascat_diurnal(active_only,active_flag,diurnal_bins,start_time{i},end_time{i});
    
    plot_ascat_diurnal(comp.(str{i}),extras.(str{i}),1,1,plot_active_only,0,0);...
        plot_ascat_diurnal(comp.(str{i}),extras.(str{i}),0,0,plot_active_only,0,0);...
        plot_ascat_diurnal(comp.(str{i}),extras.(str{i}),0,1,plot_active_only,1,0)
    
    saveas(1,['/media/andrewb1@student.unimelb.edu.au/Elements/working/figs/ascat/pert_' str{i} '_10'])
    saveas(2,['/media/andrewb1@student.unimelb.edu.au/Elements/working/figs/ascat/count_' str{i} '_10'])
    saveas(3,['/media/andrewb1@student.unimelb.edu.au/Elements/working/figs/ascat/background_' str{i} '_10'])
    saveas(4,['/media/andrewb1@student.unimelb.edu.au/Elements/working/figs/ascat/amplitude_' str{i} '_10'])
    
    close all
    
end