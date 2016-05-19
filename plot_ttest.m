function plot_ttest(Test,extras)

x=extras.start_lon+extras.d_lon/2:extras.d_lon:extras.end_lon+extras.d_lon/2;
y=extras.start_lat+extras.d_lat/2:extras.d_lat:extras.end_lat+extras.d_lat/2;

m_proj('Lambert','lat',[extras.start_lat,extras.end_lat],'lon',[extras.start_lon,extras.end_lon])
[X,Y] = meshgrid(x,y);

m_pcolor(X,Y,Test);
m_gshhs_i('color','k')
m_grid('FontSize',8)
    
end
