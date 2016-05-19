function [mean_U,mean_V,count,U,V] = ...
    ascat_avg2(start_time,end_time,nt,extras)
%22/03/2016 - Based on the code of Ewan Short
%Input: Start/end times are in vector input. Start/end Lat/Lon give the
%       range of ascat data to be binned, while extras.d_lat/lon gives the spacing (in
%       degrees) between each bin. nt defines the number of time bins which define
%       the temporal averaging period.

%Output: Output of the function is u and v wind components, deperated into
%        time bins. The function plots quivers for each bin.

%Initialise time variables and vectors
start_num = datenum(start_time);
end_num = datenum(end_time);
ascat_start = datenum([1990 01 01 00 00 00]);
dt=etime(end_time,start_time)/nt;
t=0:dt:etime(end_time,start_time)-dt;

%Get files within the unzipped ascat folder which have start times within
%the start/end inputs. Load these files into a structure using 'load_data'.
tic
cd /media/andrewb1@student.unimelb.edu.au/Elements/working/ascat/unzipped
f = dir;
cnt = 1;
for i = 3:length(f)
    file_date = f(i).name(7:14);
    file_time = f(i).name(16:21);
    if (datenum([file_date file_time],'yyyymmddHHMMSS') >= start_num) ...
            && (datenum([file_date file_time],'yyyymmddHHMMSS') <= end_num)
        files{cnt} = f(i).name;
        cnt = cnt+1;
    end
end
a=toc;

%Initialise lat and lon vectors and all bins.
x=extras.start_lon+extras.d_lon/2:extras.d_lon:extras.end_lon+extras.d_lon/2;
y=extras.start_lat+extras.d_lat/2:extras.d_lat:extras.end_lat+extras.d_lat/2;
count = ones(length(y),length(x),length(t));
ascat_speed = cell(length(y),length(x),length(t));
ascat_dir = cell(length(y),length(x),length(t));
ascat_lat = cell(length(y),length(x),length(t));
ascat_lon = cell(length(y),length(x),length(t));
U = cell(length(y),length(x),length(t));
V = cell(length(y),length(x),length(t));

%Iterate through ascat netcdf files, find valid wind data and bin into lat,
%lon, speed and direction cells. Also create wind component cells.
tic
for i = 1:length(files)    
    ascat_struct = load_data(files(i));
    [r,c] = find((ascat_struct.time/(60*60*24)+ascat_start)>(start_num) ...
            & (((ascat_struct.time)/(60*60*24))+ascat_start)<(end_num) ...
            & ascat_struct.lat>extras.start_lat ...
            & ascat_struct.lat<extras.end_lat ...
            & ascat_struct.lon>extras.start_lon ...
            & ascat_struct.lon<extras.end_lon...
            & ~isnan(ascat_struct.wind_speed)...
            & ~isnan(ascat_struct.wind_dir));    
            for j = 1:length(r)
                    Lat=floor((ascat_struct.lat(r(j),c(j))+90-(extras.start_lat+90))/extras.d_lat)+1;
                    Lon=floor((ascat_struct.lon(r(j),c(j))-extras.start_lon)/extras.d_lon)+1;
                    T=floor(etime(datevec(ascat_start)+[0 0 0 0 0 ascat_struct.time(r(j),c(j))],start_time)/dt)+1;
                    ascat_lat{Lat,Lon,T}(count(Lat,Lon,T)) = ascat_struct.lat(r(j),c(j));
                    ascat_lon{Lat,Lon,T}(count(Lat,Lon,T)) = ascat_struct.lon(r(j),c(j));
                    ascat_speed{Lat,Lon,T}(count(Lat,Lon,T)) = ascat_struct.wind_speed(r(j),c(j));
                    ascat_dir{Lat,Lon,T}(count(Lat,Lon,T)) = ascat_struct.wind_dir(r(j),c(j));
                    V{Lat,Lon,T}(count(Lat,Lon,T)) = ascat_speed{Lat,Lon,T}(count(Lat,Lon,T))*cosd(ascat_dir{Lat,Lon,T}(count(Lat,Lon,T)));
                    U{Lat,Lon,T}(count(Lat,Lon,T)) = ascat_speed{Lat,Lon,T}(count(Lat,Lon,T))*sind(ascat_dir{Lat,Lon,T}(count(Lat,Lon,T)));
                    count(Lat,Lon,T) = count(Lat,Lon,T)+1;
            end
end
b=toc;

%Take the mean of the wind components for each time bin.
tic
mean_V = cell(length(t));
mean_U = cell(length(t));
for i = 1:length(t)
    for j = 1:length(y)
        for k = 1:length(x)
            mean_V{i}(j,k) = nanmean(V{j,k,i}(:));
            mean_U{i}(j,k) = nanmean(U{j,k,i}(:));
        end
    end
end
c = toc;
end