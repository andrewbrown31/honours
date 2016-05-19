curnum = datenum(extras.start_time);
endnum = datenum(extras.end_time);
cnt = 1;
while curnum <= endnum
    str = ['d' datestr(curnum,'yymmdd')];
    count1(cnt) = ascat_struct.count.(str){1}(10,20);
    count4(cnt) = ascat_struct.count.(str){4}(10,20);
    curnum = curnum+1;
    cnt = cnt+1;
end