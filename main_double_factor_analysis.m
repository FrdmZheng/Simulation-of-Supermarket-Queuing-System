num_of_simulation = 50; % 仿真次数
rng(666, "twister");

for i = 1:2
    for j = 1:2
        waitlist = [];
        for k = 1:num_of_simulation
            % 初始化
            C.N = i + 4; % 柜台数量
            C.lambdaA = 5; % 顾客到达（人/min）
            C.lambdaG = 0.1; % 顾客购买（人/min）
            C.lambdaS = j / 5 + 0.8;  % 服务强度（人/min）
            % 初始化柜台状态
            for g = 1:C.N
                Gui(g).Qu = 0; % 排队人数为0
                Gui(g).Bu = 0; % 空闲（空闲0；繁忙1）
                Gui(g).Arrivaltime = []; % 顾客到达时刻
                Gui(g).Leavetime = []; % 顾客离开时刻
                Gui(g).cus = []; % 顾客编号
                Gui(g).wait = []; % 顾客等待时间
                Gui(g).stay = []; % 顾客停留时间
                Gui(g).S = -1 / C.lambdaS .* log(rand(1, 1000)); % 柜台服务时间序列
                Gui(g).QuHistory = []; % 排队长度历史
            end
            output = Sim(C, Gui, 0); % 一次仿真结果
            waitlist = [waitlist, mean([output.meanwait])]; % 平均等待时间列表
        end
        if i == 1
            factor = j;
        elseif i ==2
            factor = j + 2;
        end
        waitmatrix(factor).waitlist = waitlist;
        waitmatrix(factor).sum = sum(waitlist);
        waitmatrix(factor).mean = mean(waitlist);
        waitmatrix(factor).var = var(waitlist);
        waitmatrix(factor).ss = (num_of_simulation - 1) * waitmatrix(factor).var;
    end
end
T1j = waitmatrix(1).sum + waitmatrix(2).sum;
T2j = waitmatrix(3).sum + waitmatrix(4).sum;
Ti1 = waitmatrix(1).sum + waitmatrix(3).sum;
Ti2 = waitmatrix(2).sum + waitmatrix(4).sum;
N = num_of_simulation * 4;
G = waitmatrix(1).sum + waitmatrix(2).sum + waitmatrix(3).sum + waitmatrix(4).sum;
% 计算ΣX^2
square_sigma_X = 0;
for i = 1:4
    for j = 1:50
        templst = waitmatrix(i).waitlist;
        square_sigma_X = square_sigma_X + templst(j)^2;
    end
end

Se = waitmatrix(1).ss + waitmatrix(2).ss + waitmatrix(3).ss + waitmatrix(4).ss;
St = square_sigma_X - G^2 / N;
S = St - Se; % 处理间
Sa = T1j^2 / num_of_simulation / 2 + T2j^2 / num_of_simulation / 2 - G^2 / N; % 柜台数目
Sb = Ti1^2 / num_of_simulation / 2 + Ti2^2 / num_of_simulation / 2 - G^2 / N; % 服务强度
Sab = S - Sa - Sb;
MSa = Sa / 1;
MSb = Sb / 1;
MSab = Sab / 1;
MSe = Se / (4 * num_of_simulation - 4);
Fa = MSa / MSe;
Fb = MSb / MSe;
Fab = MSab / MSe;
F1_196 = 3.84;
F1_120 = 3.92;