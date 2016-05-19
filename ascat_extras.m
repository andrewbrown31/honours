function extras = ascat_extras
%Generate extras for input into ascat binning functions. Contains spatial
%bin information. Ascat_diurnal function adds the start and end times used
%in the function to the extras structure.
extras.start_lat = -16;
extras.end_lat = -7;
extras.start_lon = 122;
extras.end_lon = 140;
extras.d_lat = .5;
extras.d_lon = .5;
extras.t = .1; %composites thrown out in grid boxes where the count is lower than max(count)*t (if t_flag is on)
extras.t_flag = 1;
extras.day_avg = 3; %defines running average length for mean wind calculation
extras.avg_flag = 2; %1 = old way, 2 = new way. In regards to getting background wind. New way averages less (more information content)
extras.t_start1 = [-14.5,136];   %Transect start and end lat/lons (transect1)
extras.t_end1 = [-14.8,140];
extras.t_start2 = [-13.5,129.85];
extras.t_end2 = [-9.4,125.3];
extras.t_start3 = [-11.75,134.75];   %Transect start and end lat/lons (transect1)
extras.t_end3 = [-8,136];
end