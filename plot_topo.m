function plot_topo
m_proj('Mercator','latitude',[-20,0],'longitude',[120,145])
dar_lon = ncread('darwin_static.nc','XLONG');
dar_lat = ncread('darwin_static.nc','XLAT');
m_gshhs_i('patch',[.8 .8 .8]);m_grid;
m_text(131,-12-27/60,'\bullet Darwin ','Color','k','HorizontalAlignment','left','FontSize',8);
title('WRF and ACCESS Models Darwin Domain')

[wrfX,wrfY]=m_ll2xy([122.7421,138.9734],[-16.3081,-6.7276]);
[aX,aY]=m_ll2xy([128.5,139.984],[-16,-7.972]);
wrfplotx = [wrfX(1),wrfX(1),wrfX(2),wrfX(2),wrfX(1)];
wrfploty = [wrfY(1),wrfY(2),wrfY(2),wrfY(1),wrfY(1)];
hold on;h1 = plot(wrfplotx,wrfploty,'--');legend
aplotx = [aX(1),aX(1),aX(2),aX(2),aX(1)];
aploty = [aY(1),aY(2),aY(2),aY(1),aY(1)];
hold on;h2 = plot(aplotx,aploty,'r--');m_legend('WRF','ACCESS-C')