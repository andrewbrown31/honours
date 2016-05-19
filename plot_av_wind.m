function [uBin vBin]=plot_av_wind(netCDFarray,dLat,startLat,endLat,...
    dLon,startLon,endLon,dt,startTime,endTime)
% plot_wind_dir.m ----------------------------------------------------------
% 
% Copyright Ewan Short 23/2/2016
%
% DESC: This function takes wind direction from netCDF format at time point in 
% column t and plots.
%
% INPUTS: netCDFarray is an array containing the netcdfstructs, 
% dLat and dLon are the
% size of lat and lon increments respectively, dt time increment in 
% seconds. Note the
% time variable in the netCDF data is measured in seconds since 1/1/1990
% midnight. tRange is a vector [startTime endTime] with components in
% same units. 
%
% OUTPUT: Output the binned u and v component winds. 
%
%--------------------------------------------------------------------------

Nx=(endLon-startLon)/dLon;
Ny=(endLat-startLat)/dLat;
Nt=(endTime-startTime)/dt;

if(~(Nx == floor(Nx)) || ~(Ny == floor(Ny)) || ~(Nt == floor(Nt)) )
    error('Invalid ranges or increments');
end
   
% Adjust so average of bin is center of bin.
x=startLon+dLon/2:dLon:endLon+dLon/2;
y=startLat+dLat/2:dLat:endLat+dLat/2; 
t=startTime:dt:endTime;

% Specify time range and time increment (e.g half day). Ensure increment 
% evenly divides range. Recall
% netCDF time variable in seconds since 1/1/1990 midnight.

uBin=cell(length(x),length(y),length(t));
uBin(:)={0}; % Initialise so that if there are data gaps we won't get NaN.
vBin=cell(length(x),length(y),length(t));
vBin(:)={0};
% Variable to store number of measurements in each bin.
count=ones(length(x),length(y),length(t));

for k=1:length(netCDFarray)
    netCDF=netCDFarray(k);

    for i=1:size(netCDF.lat,1) % Iterate over swath.
        for j=1:size(netCDF.lat,2) % Iterate over time.

            if ( ~isnan(netCDF.wind_speed(i,j)) && ...
                    ~(isnan(netCDF.wind_dir(i,j))) && ...
                    netCDF.time(i,j)>=startTime && ...
                    netCDF.time(i,j)<=endTime && ...
                    netCDF.lat(i,j)>=startLat && ...
                    netCDF.lat(i,j)<=endLat && ...
                    netCDF.lon(i,j)>=startLon && ...
                    netCDF.lon(i,j)<=endLon)

                kLat=floor((netCDF.lat(i,j)+90-(startLat+90))/dLat)+1;
                kLon=floor((netCDF.lon(i,j)-startLon)/dLon)+1;
                kT=floor((netCDF.time(i,j)-startTime)/dt)+1;

                if (~(kLat==floor(kLat)) || ~(kLon==floor(kLon)) || ~(kT==floor(kT)))
                    fprintf('One of %i, %i, %i invalid.', kLat,kLon,kT);
                    error('Invalid kLat, kLon or kT.');
                end

                if (kLon>length(x) || kLat>length(y) || kT>length(t))                
                    fprintf('One of %i, %i, %i too long.', kLat,kLon,kT);
                    error('kLat, kLon or kT too long.');
                end

                uBin{kLon,kLat,kT}(count(kLon,kLat,kT))=netCDF.wind_speed(i,j)*...
                    sind(netCDF.wind_dir(i,j));
                vBin{kLon,kLat,kT}(count(kLon,kLat,kT))=netCDF.wind_speed(i,j)*...
                    cosd(netCDF.wind_dir(i,j));

                % Add one to number of measurements in this bin. 
                count(kLon,kLat,kT)=count(kLon,kLat,kT)+1;

            end

        end
    end
    
end

u=zeros(length(x),length(y),length(t));
v=zeros(length(x),length(y),length(t));

for i=1:length(x)
    for j=1:length(y)
        for k=1:length(t)
        
            u(i,j,k)=mean(uBin{i,j,k});
            v(i,j,k)=mean(vBin{i,j,k});
            
        end
    end
end       


[X Y]=meshgrid(x,y);
figure
m_proj('equidistant cylindrical','longitudes',[startLon endLon], ...
'latitudes',[startLat endLat]);
m_quiver(X,Y,mean(u,3)',mean(v,3)');
m_coast('linewidth',1,'color','black');
m_grid('xtick',0,'ytick',0);

end

