%Plot position of Darwin and Van Diemen Gulf
m_proj('Lambert','lat',[-14,-10],'lon',[129,134]);
close all;
figure;
m_grid;
m_gshhs_i('patch',[.8 .8 .8]);
m_text(131,-12.4628,'\bullet Darwin','HorizontalAlignment','left');
m_text(131.75,-11.9,'\it Van Diemen Gulf','HorizontalAlignment','center','FontSize',8)
m_text(130.9,-11.6,'\it Tiwi Islands','HorizontalAlignment','center','FontSize',8)

axes('Position',[.25 .7 .2 .2])
box on
m_proj('Mercator','lat',[-45,-10],'lon',[110,160]);
m_grid('box','on','xticklabels','','yticklabels','','xtick',[],'ytick',[]);
m_gshhs_i('patch',[.8 .8 .8])
m_ungrid;
set(gca,'xticklabels','')
set(gca,'yticklabels','')