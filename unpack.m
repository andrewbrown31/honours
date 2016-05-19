cd('F:\working\ascat\coastal_opt\metop_b\podaac-ftp.jpl.nasa.gov\allData\ascat\preview\L2\metop_b\coastal_opt');
for year = 2014:2015
    cd(num2str(year));
    a = dir;
    [m,~] = size(a);
    for n = 3:m
            cd(a(n).name);
            gunzip('*.gz','F:\working\ascat\unziped')
            cd('..')
    end
    cd('..')
end