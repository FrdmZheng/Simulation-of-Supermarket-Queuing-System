num_of_simulation = 50; % 仿真次数
rng(666, "twister");

for factor = 5:8
    waitlist = [];
    for i = 1:num_of_simulation
        % 初始化
        C.N = factor; % 柜台数量
        C.lambdaA = 5; % 顾客到达（人/min）
        C.lambdaG = 0.1; % 顾客购买（人/min）
        C.lambdaS = 1;  % 服务强度（人/min）
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
    waitmatrix(factor).waitlist = waitlist;
    waitmatrix(factor).sum = sum(waitlist);
    waitmatrix(factor).mean = mean(waitlist);
    waitmatrix(factor).var = var(waitlist);
    waitmatrix(factor).ss = (num_of_simulation - 1) * waitmatrix(factor).var;
end
% 计算Se
Se = 0;
for factor = 5:8
    Se = Se + waitmatrix(factor).ss;
end
% 计算Sa
T = 0;
for factor = 5:8
    T = T + waitmatrix(factor).sum;
end
% Sa = - T^2 / num_of_simulation * length(5:8);
% for factor = 5:8
%     Sa = Sa + (waitmatrix(factor).sum^2 / num_of_simulation);
% end
Sa = 0;
for factor = 5:8
    Sa = Sa + num_of_simulation * (waitmatrix(factor).mean - T / (num_of_simulation * length(5:8)))^2;
end
% 计算MSe和MSa
MSe = Se / (num_of_simulation * length(5:8) - length(5:8));
MSa = Sa / (length(5:8) - 1);
F = MSa / MSe; % 检验统计量
F3_196 = 3.6;
F3_10 = 3.71;

% HSD检验
fse = num_of_simulation * length(5:8) - length(5:8);
q4_120 = 3.917;
q4_240 = 3.887;
q4_196 = q4_120 - (q4_240 - q4_120) * (196 - 120) / (240 - 120);
HSD = q4_196 * sqrt(MSe / num_of_simulation);
