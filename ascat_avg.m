function [struct_cond,vBin,uBin] = ascat_avg(struct,start_time,end_time,lat_lim,lon_lim,diff,Nt)
% diff = [dx,dy,Nt]
%Start, end times are date vectors

ascat_start = [1990 01 01 00 00 00];
ascat_start_num = datenum(ascat_start);
end_time_num = datenum(end_time);
start_time_num = datenum(start_time);
%%%EWAN
Nx=(lon_lim(2)-lon_lim(1))/diff(1);
Ny=(lat_lim(2)-lat_lim(1))/diff(2);
dt=etime(end_time,start_time)/Nt;

if(~(Nx == floor(Nx)) || ~(Ny == floor(Ny)) || ~(Nt == floor(Nt)) )
    error('Invalid ranges or increments');
end
   
% Adjust so average of bin is center of bin.
x=lon_lim(1)+diff(1)/2:diff(1):lon_lim(2)+diff(1)/2;
y=lat_lim(1)+diff(2)/2:diff(2):lat_lim(2)+diff(2)/2;
% Create time vector as seconds since start time for binning.
t=0:dt:etime(end_time,start_time)-dt;
% Recall ascat time values are measured in seconds since 1/1/1990 midnight.
% Include option to add leap seconds manually. 

uBin=cell(length(struct),1); %? Initialise so that if there are data gaps we won't get NaN.
vBin=cell(length(struct),1);
uBin(:)={NaN};
vBin(:)={NaN};
%%%
i_cnt = 1;
for i = 1:length(struct)
    i_size = size(struct(i).time);
    j_cnt=1;
    for j = 1:i_size(1)
        k_cnt=1;
        for k = 1:i_size(2)
            if (((struct(i).time(j,k))/(60*60*24))+ascat_start_num)>(start_time_num) ...
                    && (((struct(i).time(j,k))/(60*60*24))+ascat_start_num)<(end_time_num) ...
                    && struct(i).lat(j,k)>lat_lim(1) ...
                    && struct(i).lat(j,k)<lat_lim(2) ...
                    && struct(i).lon(j,k)>lon_lim(1) ...
                    && struct(i).lon(j,k)<lon_lim(2)
                struct_cond{i_cnt}(j_cnt,k_cnt) = 1;
            else
                struct_cond{i_cnt}(j_cnt,k_cnt) = 0;
            end
            k_cnt = k_cnt+1;
        end
        j_cnt = j_cnt+1;
    end
    i_cnt = i_cnt+1;
end

for i = 1:length(struct)
    [a,b] = find(struct_cond{i});
    for j = 1:length(a)
                xyt_info = [floor(struct(i).lat(a(j),b(j))+90-((lat_lim(1)+90)/diff(2)))+1,...
                    floor(struct(i).lon(a(j),b(j))-lon_lim(1)/diff(1))+1, ...
                    floor(etime(ascat_start+[0 0 0 0 0 struct(i).time(a(j),b(j))],start_time)/dt)+1];
                uBin{i}(xyt_info(1),xyt_info(2),xyt_info(3))=struct(i).wind_speed(a(j),b(j))*...
                        sind(struct(i).wind_dir(a(j),b(j)));
                vBin{i}(xyt_info(1),xyt_info(2),xyt_info(3))=struct(i).wind_speed(a(j),b(j))*...
                        cosd(struct(i).wind_dir(a(j),b(j)));
        
    end
end


end
