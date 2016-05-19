function plot_ascat_diurnal_transects(comp,extras,comp2,extras2)
    %Plots amplitude of the diurnal cycle from the ascat structure 'comp',
    %before plotting transects of the diurnal cycle defined in extras. Note
    %that plot_ascat_diurnal also plots the amplitude of the diurnal cycle
    %(with wind vectors).

    %Create original lat/lon grid
    x=extras.start_lon+extras.d_lon/2:extras.d_lon:extras.end_lon+extras.d_lon/2;
    y=extras.start_lat+extras.d_lat/2:extras.d_lat:extras.end_lat+extras.d_lat/2;
    [X,Y] = meshgrid(x,y);
    
    %Plot diurnal amplitude contour plot for 'comp'
    figure
    m_proj('Lambert','lat',[extras.start_lat,extras.end_lat],'lon',[extras.start_lon,extras.end_lon])
    m_contourf(X,Y,(comp.diff_U{4}.^2 + comp.diff_V{4}.^2).^(1/2),'LineColor','none')
    m_gshhs_i('color','k')
    m_grid('FontSize',8);title(['Amplitude of ' comp.period ' Diurnal Cycle'])
    
    %Add transect lines to the contour map (also execute 'transect')
    t = transect(comp,extras);
    [trans_xy1,trans_xy2] = m_ll2xy([extras.t_start1(2),extras.t_end1(2)],[extras.t_start1(1),extras.t_end1(1)]);
    line(trans_xy1,trans_xy2,'Color','r')
    [trans_xy3,trans_xy4] = m_ll2xy([extras.t_start2(2),extras.t_end2(2)],[extras.t_start2(1),extras.t_end2(1)]);
    line(trans_xy3,trans_xy4,'Color','r')
    [trans_xy5,trans_xy6] = m_ll2xy([extras.t_start3(2),extras.t_end3(2)],[extras.t_start3(1),extras.t_end3(1)]);
    line(trans_xy5,trans_xy6,'Color','r')
    caxis([0,4]);
    colorbar('southoutside','Position',[.25 .05 .5 .025])
    
    %If there's a comp2, plot diurnal amplitude for that with transects
    if nargin > 2
        figure
        m_contourf(X,Y,(comp2.diff_U{4}.^2 + comp2.diff_V{4}.^2).^(1/2),'LineColor','none')
        m_gshhs_i('color','k')
        m_grid('FontSize',8);title(['Amplitude of ' comp2.period ' Diurnal Cycle'])
        line(trans_xy1,trans_xy2,'Color','r')
        line(trans_xy3,trans_xy4,'Color','r')
        line(trans_xy5,trans_xy6,'Color','r')
        caxis([0,4]);
        colorbar('southoutside','Position',[.25 .05 .5 .025])
    end
    
    hold off;
    %Plot first transect as a line graph
    figure;
    plot(t.index1,t.amp1);
    ax=gca;ax.FontSize = 10;
    ax.XTick = t.index1(1):2:t.index1(end-1);
    ax.XLim = [t.index1(1),t.index1(end-1)];
    for i = 1:length(ax.XTick)
        ax.XTickLabel{i} = t.distance1{ax.XTick(i)};
    end
    title(['Diurnal Amplitude Transect ',t.coords_str1(1),t.coords_str1(end)]);ylabel('Amplitude (m/s)')
    if nargin > 2
        hold on
        t2 = transect(comp2,extras2);
        plot(t2.index1,t2.amp1);legend(comp.period,comp2.period)
    end
    ax.YTickLabels{1} = '';
    xlabel('Distance from start point (km)')
    
    %Plot second transect
    figure;
    plot(t.index2,t.amp2);
    ax=gca;ax.FontSize = 10;
    ax.XTick = t.index2(1):2:t.index2(end-1);
    ax.XLim = [t.index2(1),t.index2(end-1)];
    for i = 1:length(ax.XTick)
        ax.XTickLabel{i} = t.distance2{ax.XTick(i)};
    end
    title(['Diurnal Amplitude Transect ',t.coords_str2(1),t.coords_str2(end)]);ylabel('Amplitude (m/s)')
    if nargin > 2
        hold on
        plot(t2.index2,t2.amp2);legend(comp.period,comp2.period)
    end
    ax.YTickLabels{1} = '';
    xlabel('Distance from start point (km)')
    
    %Plot third transect
    figure;
    plot(t.index3,t.amp3);
    ax=gca;ax.FontSize = 10;
    ax.XTick = t.index3(1):t.index3(end-1);
    ax.XLim = [t.index3(1),t.index3(end-1)];
    title(['Diurnal Amplitude Transect ',t.coords_str3(1),t.coords_str3(end)]);ylabel('Amplitude (m/s)')
    for i = 1:length(ax.XTick)
        ax.XTickLabel{i} = t.distance3{ax.XTick(i)};
    end
    if nargin > 2
        hold on
        plot(t2.index3,t2.amp3);legend(comp.period,comp2.period)
    end
    ax.YTickLabels{1} = '';
    xlabel('Distance from start point (km)')
end