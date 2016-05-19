function t = transect(comp,extras)
% This function takes a composite as input, and averages along a transect
% defined by extras.t_start/end. The function creates bins along the
% transect of size d_lat*d_lon. If one value lies within the bin then that
% is the value along the transect at that point. If more than one value is
% present, then the values are averaged.
%Output is in a data structure, t.

%Create original lat/lon matrix and meshgrid
x_t=extras.start_lon+extras.d_lon/2:extras.d_lon:extras.end_lon+extras.d_lon/2;
y_t=extras.start_lat+extras.d_lat/2:extras.d_lat:extras.end_lat+extras.d_lat/2;
[X_T,Y_T] = meshgrid(x_t,y_t);

%Find the length of each transect line, allowing the line to be spaced the
%same as the spatial bins.
line_length = [((max([extras.t_end1(2),extras.t_start1(2)]) - min([extras.t_end1(2),extras.t_start1(2)]))^2 ...
                    + (max([extras.t_end1(1),extras.t_start1(1)]) - min([extras.t_end1(1),extras.t_start1(1)]))^2)^(1/2),...
              ((max([extras.t_end2(2),extras.t_start2(2)]) - min([extras.t_end2(2),extras.t_start2(2)]))^2 ...
                    + (max([extras.t_end2(1),extras.t_start2(1)]) - min([extras.t_end2(1),extras.t_start2(1)]))^2)^(1/2),...
              ((max([extras.t_end3(2),extras.t_start3(2)]) - min([extras.t_end3(2),extras.t_start3(2)]))^2 ...
                    + (max([extras.t_end3(1),extras.t_start3(1)]) - min([extras.t_end3(1),extras.t_start3(1)]))^2)^(1/2)];
n = line_length./extras.d_lat + 1;

%Create new x and y bins along transects to be interpolated onto. Must
%start with the minimum lat/lon. 
t.x_t1 = linspace(min([extras.t_end1(2),extras.t_start1(2)]),max([extras.t_end1(2),extras.t_start1(2)]),...
    n(1));
t.y_t1 = linspace(min([extras.t_end1(1),extras.t_start1(1)]),max([extras.t_end1(1),extras.t_start1(1)]),...
    n(1));
t.x_t2 = linspace(min([extras.t_end2(2),extras.t_start2(2)]),max([extras.t_end2(2),extras.t_start2(2)]),...
    n(2));
t.y_t2 = linspace(min([extras.t_end2(1),extras.t_start2(1)]),max([extras.t_end2(1),extras.t_start2(1)]),...
    n(2));
t.x_t3 = linspace(min([extras.t_end3(2),extras.t_start3(2)]),max([extras.t_end3(2),extras.t_start3(2)]),...
    n(3));
t.y_t3 = linspace(min([extras.t_end3(1),extras.t_start3(1)]),max([extras.t_end3(1),extras.t_start3(1)]),...
    n(3));

%First Transect
for i = [1,4]
    t.diff_U1{i} = interp2(X_T,Y_T,comp.diff_U{i},t.x_t1,t.y_t1);
    t.diff_V1{i} = interp2(X_T,Y_T,comp.diff_V{i},t.x_t1,t.y_t1);
end
t.amp1 = (t.diff_U1{1}.^2 + t.diff_V1{1}.^2).^(1/2); 
for i = 1:n(1)
    t.index1(i) = i;
    t.coords_lon1{i} = num2str(t.x_t1(i));
    t.coords_lat1{i} = num2str(t.y_t1(i));
    t.coords_str1{1,i} = [t.coords_lon1{i} ', ' t.coords_lat1{i}];
    t.distance1{i} = num2str(round(deg2km(distance('gc',t.y_t1(1),t.x_t1(1),t.y_t1(i),t.x_t1(i)))));
end

%Second transect
for i = [1,4]
    t.diff_U2{i} = interp2(X_T,Y_T,comp.diff_U{i},t.x_t2,t.y_t2);
    t.diff_V2{i} = interp2(X_T,Y_T,comp.diff_V{i},t.x_t2,t.y_t2);
end
t.amp2 = (t.diff_U2{1}.^2 + t.diff_V2{1}.^2).^(1/2); 
for i = 1:n(2)
    t.index2(i) = i;
    t.coords_lon2{i} = num2str(t.x_t2(i));
    t.coords_lat2{i} = num2str(t.y_t2(i));
    t.coords_str2{1,i} = [t.coords_lon2{i} ', ' t.coords_lat2{i}];
    t.distance2{i} = num2str(round(deg2km(distance('gc',t.y_t2(1),t.x_t2(1),t.y_t2(i),t.x_t2(i)))));
end

%Third transect
for i = [1,4]
    t.diff_U3{i} = interp2(X_T,Y_T,comp.diff_U{i},t.x_t3,t.y_t3);
    t.diff_V3{i} = interp2(X_T,Y_T,comp.diff_V{i},t.x_t3,t.y_t3);
end
t.amp3 = (t.diff_U3{1}.^2 + t.diff_V3{1}.^2).^(1/2); 
for i = 1:n(3)
    t.index3(i) = i;
    t.coords_lon3{i} = num2str(t.x_t3(i));
    t.coords_lat3{i} = num2str(t.y_t3(i));
    t.coords_str3{1,i} = [t.coords_lon3{i} ', ' t.coords_lat3{i}];
    t.distance3{i} = num2str(round(deg2km(distance('gc',t.y_t3(1),t.x_t3(1),t.y_t3(i),t.x_t3(i)))));
end
end