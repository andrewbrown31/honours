function [u,v,count]=Ewan_ascat_wind(dLat,startLat,endLat,...
    dLon,startLon,endLon,Nt,startTime,endTime)
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
% same units. If averageTimes is 1, average data for given time bins across
% all days in data range. 
%
% OUTPUT: Output the binned average u and v component winds and a count of 
% how many measurements were in each bin for averaging purposes. 
%
%--------------------------------------------------------------------------


cd E:\working\ascat\unzipped
f = dir;
cnt = 1;
for i = 3:length(f)
    file_date = f(i).name(7:14);
    file_time = f(i).name(16:21);
    if (datenum([file_date file_time],'yyyymmddHHMMSS') >= datenum(startTime)) ...
            && (datenum([file_date file_time],'yyyymmddHHMMSS') <= datenum(endTime))
        files{cnt} = f(i).name;
        cnt = cnt+1;
    end
end
netCDFarray = load_data(files);


Nx=(endLon-startLon)/dLon;
Ny=(endLat-startLat)/dLat;
dt=etime(endTime,startTime)/Nt;

if(~(Nx == floor(Nx)) || ~(Ny == floor(Ny)) || ~(Nt == floor(Nt)) )
    error('Invalid ranges or increments');
end
   
% Adjust so average of bin is center of bin.
x=startLon+dLon/2:dLon:endLon+dLon/2;
y=startLat+dLat/2:dLat:endLat+dLat/2;
% Create time vector as seconds since start time for binning.
t=0:dt:etime(endTime,startTime)-dt;
% Recall ascat time values are measured in seconds since 1/1/1990 midnight.
% Include option to add leap seconds manually. 
ascatStart=[1990 01 01 0 0 0];

uBin=cell(length(x),length(y),length(t));
uBin(:)={0}; % Initialise so that if there are data gaps we won't get NaN.
vBin=cell(length(x),length(y),length(t));
vBin(:)={0};
% Variable to store number of measurements in each bin.
count=ones(length(x),length(y),length(t));
    
for k=1:length(netCDFarray)
    netCDF=netCDFarray(k);
    fprintf('Binning %s \n', netCDF.filename(end-58:end)); 
    
    for i=1:size(netCDF.lat,1) % Iterate over swath.
        for j=1:size(netCDF.lat,2) % Iterate over time.

            if ( ~isnan(netCDF.wind_speed(i,j)) && ...
                    ~(isnan(netCDF.wind_dir(i,j))) && ...
                    etime(ascatStart+[0 0 0 0 0 netCDF.time(i,j)],startTime)>=0 && ...
                    etime(endTime,ascatStart+[0 0 0 0 0 netCDF.time(i,j)])>=0 && ...
                    netCDF.lat(i,j)>=startLat && ...
                    netCDF.lat(i,j)<=endLat && ...
                    netCDF.lon(i,j)>=startLon && ...
                    netCDF.lon(i,j)<=endLon)

                kLat=floor((netCDF.lat(i,j)+90-(startLat+90))/dLat)+1;
                kLon=floor((netCDF.lon(i,j)-startLon)/dLon)+1;
                kT=floor(etime(ascatStart+[0 0 0 0 0 netCDF.time(i,j)],startTime)/dt)+1;
                
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

fprintf('Averaging data in each bin. \n');

for i=1:length(x)
    for j=1:length(y)
        for k=1:length(t)
            if count(i,j,k)>1

                u(i,j,k)=mean(uBin{i,j,k});
                v(i,j,k)=mean(vBin{i,j,k}); 

            end
        end
    end
    fprintf('%i percent completed. \n', floor(100*i/length(x)));
end       

fprintf('Plotting. \n');

[X Y]=meshgrid(x,y);
m_proj('equidistant cylindrical','longitudes',[startLon endLon], ...
'latitudes',[startLat endLat]);
for i=1:length(t)
    figure
    m_quiver(X,Y,u(:,:,i)',v(:,:,i)');
    m_coast('linewidth',1,'color','black');
    m_grid('xtick',0,'ytick',0);
    
    timeInterval=sprintf(['Average winds between ' ...
        datestr(datenum(startTime)+(i-1)*datenum(dt/(24*60*60)),0) ' and ' ... 
        datestr(datenum(startTime)+i*datenum(dt/(24*60*60)),0) '.\n']);
    title(timeInterval);
end

end