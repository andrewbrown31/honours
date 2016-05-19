function [netCDFarray] = load_data(files)
%Now loads from a cell, named 'files'. To go back to getting files from the
%working directory rename input to names, uncomment.

% names = dir(files);
% names = {names.name};

for i=1:length(files)
    
    [info,out]=read_nc_file_struct(files{i});
    netCDFarray(i)=out;
    
end

end

