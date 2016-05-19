function Test = TTest(struct)
[r,c,d] = size(struct.pert_U{1});
amp_daily = zeros(r,c,d);
diff_U = zeros(r,c,d);
diff_V = zeros(r,c,d);
amp_diurnal = zeros(r,c,d);
for i = 1:r
    for j = 1:c
        for k = 1:d
            amp_daily(i,j,k) = (struct.daily_U(i,j,k)^2 + struct.daily_V(i,j,k)^2)^(1/2);
            diff_U(i,j,k) = struct.mean2_U{4}(i,j,k) - struct.mean2_U{1}(i,j,k);
            diff_V(i,j,k) = struct.mean2_V{4}(i,j,k) - struct.mean2_V{1}(i,j,k);
            amp_diurnal(i,j,k) = (diff_U(i,j,k)^2 + diff_V(i,j,k)^2)^(1/2);
        end
    end
end

Test = zeros(r,c);
for i = 1:r
    for j = 1:c
        [Test(i,j),~,~,~] = ttest2(amp_diurnal(i,j,:),amp_daily(i,j,:));
    end
end
% [ru,cu] = find(Test_U == 1 & Test_V == 1);
% [rs,cs] = find(Test_U == 0 & Test_V == 0);
% for i = 1:length(ru)
%     amp_u(ru(i),cu(i)) = comp.ws.pert{1}(ru(i),cu(i)) - comp.ws.pert{4}(ru(i),cu(i));
% end
% for i = 1:length(rs)
%     amp_s(rs(i),cs(i)) = comp.ws.pert{1}(rs(i),cs(i)) - comp.ws.pert{4}(rs(i),cs(i));
% end
end