function plot_ascat_diurnal(comp,extras,count_flag,pert_flag,active_flag,amp_flag)
%This function plots u and v ascat vectors as outputted by ascat_diurnal.
%The function also plots each daily time bin composite, and comp.counts for each
%bin.
%Active flag just changes the title. 1 gives 'active period', 0 for 
%'start time - end time', 2 gives 'non active period start time - end time'
%Pert flag indicates if the plots are for perturbation or mean winds.
%amp_flag toggles contour of the diurnal amplitude.
%transect flag toggles transect plots defined y extras.

%Find which diurnal bins have data
filled_cnt = 1;
for i = 1:length(comp.count)
    if max(max(comp.count{i})) ~= 0
       filled(filled_cnt) = i;
       filled_cnt = filled_cnt + 1;
    end
end

if pert_flag
   for i = 1:length(filled)
        ws(i) = max(max(comp.ws.pert{filled(i)}));
   end
   U = comp.pert_U;
   V = comp.pert_V;
else
   for i = 1:length(filled) 
        ws(i) = max(max(comp.ws.mean{filled(i)}));
   end
   U = comp.mean_U;
   V = comp.mean_V;
end

x=extras.start_lon+extras.d_lon/2:extras.d_lon:extras.end_lon+extras.d_lon/2;
y=extras.start_lat+extras.d_lat/2:extras.d_lat:extras.end_lat+extras.d_lat/2;
x1=(extras.start_lon):extras.d_lon:(extras.end_lon+extras.d_lon);
y1=(extras.start_lat):extras.d_lat:(extras.end_lat+extras.d_lat);
m_proj('Lambert','lat',[extras.start_lat,extras.end_lat],'lon',[extras.start_lon,extras.end_lon])
[X,Y] = meshgrid(x,y);
[X1,Y1] = meshgrid(x1,y1);
hours_int = 24/length(comp.count);

%Plot wind vectors composited over start/end time
figure
% To manually select bins
filled = [1,4];
filled_cnt = 3;
%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:length(filled)
    h{i} = subplot(1,filled_cnt-1,i);
    m_quiver(X,Y,U{filled(i)},V{filled(i)},'Color','k');
    m_gshhs_i('color','k')
    m_grid('FontSize',8)
    str = sprintf('%c%c%c%c%c - %c%c%c%c%c LT \n Maximum: %0.3f m/s',...
        datestr(extras.start_time+[0 0 0 ((filled(i)-1)*hours_int)+9 30 0],'HH:MM'),...
        datestr(extras.start_time+[0 0 0 9+(filled(i)*hours_int) 30 0],'HH:MM'),ws(i));
    title(str);
end
if pert_flag
    if active_flag == 1
        suptitle('ASCAT Perturbation Winds, Active Period')   
    elseif active_flag == 0
        suptitle(['ASCAT Perturbation Winds, ' datestr(extras.start_time,...
            'dd/mm/yyyy') ' to ' datestr(extras.end_time,'dd/mm/yyyy')])
    elseif active_flag == 2
    suptitle(['ASCAT Perturbation Winds Non-Active, ' datestr(extras.start_time,...
        'dd/mm/yyyy') ' to ' datestr(extras.end_time,'dd/mm/yyyy')])  
    end
else
    suptitle(['ASCAT Winds, ' datestr(extras.start_time,'dd/mm/yyyy') ' to ' datestr(extras.end_time,'dd/mm/yyyy')])
end

%Plot data comp.counts 
if count_flag
figure
comp_count=1;

c_max = max([max(max(comp.count{1})),max(max(comp.count{2})),max(max(comp.count{3}))...
    max(max(comp.count{4})),max(max(comp.count{5})),max(max(comp.count{6}))]);
for i = 1:length(comp.count)
    comp.count{i}(end+1,:) = 0;
    comp.count{i}(:,end+1) = 0;
    subplot(2,3,comp_count);
    m_pcolor(X1,Y1,comp.count{i}(:,:));
    m_gshhs_i('color','k')
    m_grid('FontSize',8)
    str = sprintf('%c%c%c%c%c - %c%c%c%c%c LT',...
        datestr(extras.start_time+[0 0 0 ((i-1)*hours_int)+9 30 0],'HH:MM'),...
        datestr(extras.start_time+[0 0 0 9+(i*hours_int) 30 0],'HH:MM'));
    title(str);
    caxis([0,c_max])
%     if active_flag
%         caxis([0 400])
%     end
%     if ~active_flag
%         caxis([0 1000])
%     end
    comp_count=comp_count+1;
end
colorbar('southoutside','Position',[.25 .05 .5 .05])
if active_flag
    suptitle('Data comp.count for Active Periods')
else
    suptitle(['ASCAT Data comp.count, ' datestr(extras.start_time,'dd/mm/yyyy') ' to ' datestr(extras.end_time,'dd/mm/yyyy')])
end
end

%Contour amplitude of change in wind
if amp_flag
    hold on;caxis([0,4]);
    m_contourf(X,Y,(comp.diff_U{4}.^2 + comp.diff_V{4}.^2).^(1/2),'LineColor','none')
    subplot(h{1});hold on;caxis([0,4]);
    m_contourf(X,Y,(comp.diff_U{1}.^2 + comp.diff_V{1}.^2).^(1/2),'LineColor','none')
    colorbar('southoutside','Position',[.25 .05 .5 .025])
end

end