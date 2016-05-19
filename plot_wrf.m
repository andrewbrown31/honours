function plot_wrf(fname)
%Sample function to read in a single WRF file, and interpolate and plot WRF surface wind data.
%Takes into account unstaggering of U and V.

date = fname(16:25);

%Get info for unstaggered spatial dimensions
static_info = ncinfo('darwin_static.nc');
[~,us_lat_dim,us_lon_dim] = static_info.Dimensions.Length;

%Read in unstaggered lat/lons and average.
us_lat = ncread('darwin_static.nc','XLAT');
us_lon = ncread('darwin_static.nc','XLONG');
U = squeeze(ncread(fname,'U'));
V = squeeze(ncread(fname,'V'));     %Squeeze to remove singleton height dimension
mean_U = mean(U,3);                 %Daily average
mean_V = mean(V,3);

%Create staggered meshgrids by adding/subtracting 0.5*dx from either side
%of the unstaggered start/finish. Number of points specified by unsteggered
%dimensions.
lat_s = linspace(us_lat(1,1) - km2deg(2,'earth'),us_lat(1,end) + km2deg(2,'earth'),us_lat_dim + 1);
lon_s = linspace(us_lon(1,1) - km2deg(2,'earth'),us_lon(end,1) + km2deg(2,'earth'),us_lon_dim + 1);
[X_LAT,Y_LAT] = meshgrid(lat_s,us_lon(:,1));
[X_LON,Y_LON] = meshgrid(us_lat(1,:),lon_s);

%Interpolate U and V onto unstaggered grids
U_us = interp2(X_LON,Y_LON,mean_U,us_lat,us_lon);
V_us = interp2(X_LAT,Y_LAT,mean_V,us_lat,us_lon);

%Plot
figure
m_proj('Lambert','lat',[-16,-7],'lon',[123,138]);
m_quiver(us_lon,us_lat,U_us,V_us);
m_gshhs_i('color','k');title(['WRF ' date ', Unstaggered, Native Resolution']);
m_grid;

%Interpolate to ascat resolution (say, 0.5x0.5 degrees). Done with
%unstaggered data then staggered data
lat_a = us_lat(1,1):0.5:us_lat(1,end);
lon_a = us_lon(1,1):0.5:us_lon(end,1);
[X_A,Y_A] = meshgrid(lat_a,lon_a);
U_a = interp2(us_lat,us_lon,U_us,X_A,Y_A);
V_a = interp2(us_lat,us_lon,V_us,X_A,Y_A);
U_ac = interp2(us_lat,us_lon,U_us,X_A,Y_A,'cubic');
V_ac = interp2(us_lat,us_lon,V_us,X_A,Y_A,'cubic');

U_a2 = interp2(us_lat,us_lon,mean_U(1:447,:),X_A,Y_A);
V_a2 = interp2(us_lat,us_lon,mean_V(:,1:270),X_A,Y_A);

%Plot
figure
m_quiver(Y_A,X_A,U_a,V_a);
m_grid;m_gshhs_i('color','k');title(['WRF ' date ', Unstaggered, Linear Interp, 0.5x0.5']);

%Plot staggered (cutting off end dimension length)
figure
m_quiver(Y_A,X_A,U_a2,V_a2);
m_grid;m_gshhs_i('color','k');title(['WRF ' date ', Staggered, Linear Interp, 0.5x0.5']);

%Plot cubic interp of unstaggered u and v (interpolated onto 0.5x0.5)
figure
m_quiver(Y_A,X_A,U_ac,V_ac);
m_grid;m_gshhs_i('color','k');title(['WRF ' date ', Unstaggered, Cubic Interp, 0.5x0.5']);
end