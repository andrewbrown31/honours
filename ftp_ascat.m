% f = ftp('podaac-ftp.jpl.nasa.gov','anonymous');

% cd(f,'allData/ascat/preview/L2/metop_a/coastal_opt');
% cd('E:\working\ascat\coastal_opt\metop_a');
% mget(f,'*.txt');
% 
% yr_cnt = 1;
% h = waitbar(0,'Getting metopa');
% for year = 2015:2015
%     mkdir(num2str(year));
%     addpath(num2str(year));
%     cd(num2str(year));
%     cd(f,num2str(year));
%     f_dir = dir(f);
%     [a,~] = size(f_dir);
%     for n = 166:a
%             cd(f,f_dir(n).name);
%             mkdir(f_dir(n).name)
%             addpath(f_dir(n).name)
%             cd(f_dir(n).name)
%             mget(f,'*.gz');
%             cd(f,'..')
%             cd('..')
%             waitbar((yr_cnt*n)/(a*3))
%     end
%     cd(f,'..')
%     cd('..')
%     yr_cnt = yr_cnt + 1;
% end
% close(h)

f = ftp('podaac-ftp.jpl.nasa.gov','anonymous');
cd(f,'allData/ascat/preview/L2/metop_b/coastal_opt');
cd('F:\working\ascat\coastal_opt\metop_b');
mget(f,'*.txt');

h = waitbar(0,'Getting metopb');
yr_cnt = 1;
for year = 2014:2014
    mkdir(num2str(year));
    addpath(num2str(year));
    cd(num2str(year));
    cd(f,num2str(year));
    f_dir = dir(f);
    [a,~] = size(f_dir);
    for n = 300:a
            cd(f,f_dir(n).name);
            mkdir(f_dir(n).name)
            addpath(f_dir(n).name)
            cd(f_dir(n).name)
            mget(f,'*.gz');
            cd(f,'..')
            cd('..')
            waitbar((yr_cnt*n)/(a*3))
    end
    cd(f,'..')
    cd('..')
    yr_cnt=yr_cnt+1;
end
close(h)