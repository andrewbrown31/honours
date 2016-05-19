function [prcp_accum,prcp_days] = sample_netcdf

% Define some paths
FSTUB = 'C:\Users\Andrew\Documents\Uni\Honours\working\first_data\wrf\RAINNC_daily_d02_';
FSTATIC = 'C:\Users\Andrew\Documents\Uni\Honours\working\first_data\wrf\darwin_static.nc';

% latitude and longitude

ncfile = FSTATIC;
lat = ncread(ncfile, 'XLAT');
lon = ncread(ncfile, 'XLONG');
finfo_static = ncinfo(ncfile);

% hourly precipitation


d_initial = datenum([2015,01,01,00,00,00]);
wrfdate = datestr(d_initial, 'yyyy-mm-dd');
ncfile = [FSTUB, wrfdate, '_detotal.nc'];
finfo = ncinfo(ncfile);
[nx,ny,nt] = finfo.Variables.Dimensions.Length;
prcp_accum = zeros(nx,ny);

for i = 1:31
    dstart = datenum([2015,01,i,00,00,00]);
    wrfdate = datestr(dstart, 'yyyy-mm-dd');
    wrfdate_fieldname = ['x' datestr(dstart, 'yyyy_mm_dd')];
    ncfile = [FSTUB, wrfdate, '_detotal.nc'];
    finfo = ncinfo(ncfile);
    [nx,ny,nt] = finfo.Variables.Dimensions.Length;
    t = 1;
    prcp_temp = ncread(ncfile, 'RAINNC', [1,1,t], [nx, ny, 1]);
    prcp_days.(wrfdate_fieldname) = prcp_temp;
    prcp_accum = prcp_accum+prcp_temp;
end

m_proj('lambert','lat',[-15 -7],'lon',[122 139]);
m_coast('patch',[.9 .9 .9],'edgecolor','none');
m_grid('tickdir','out','yaxislocation','right',...
    'xaxislocation','top','xlabeldir','end','ticklen',.02);
hold on
m_contour(lon, lat, prcp_accum,[50 100 150])


% Mapping: I use a free external package called mmap. There is also a
% mapping toolbox in matlab. 


