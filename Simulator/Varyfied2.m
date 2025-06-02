% 初始化
numData = readmatrix('GetT975.xlsx'); % 读取t数值数据
seed1 = 1;
waitlist = []; % 初始化平均等待时间列表
staylist = [];
Qulist = [];
maxlist = [];
BusyRatelist = [];
for i = 1:40
    % 初始化
    C.N = 5; % 柜台数量
    C.lambdaA = 5; % 顾客到达（人/min）
    C.lambdaG = 0.1; % 顾客购买（人/min）
    C.lambdaS = 1; % 服务时间（人/min）
    % 初始化柜台状态
    for g = 1:C.N
        Gui3(g).Qu = 0; % 排队人数为0
        Gui3(g).Bu = 0; % 空闲（空闲0；繁忙1）
        Gui3(g).Arrivaltime = []; % 顾客到达时刻
        Gui3(g).Leavetime = []; % 顾客离开时刻
        Gui3(g).cus = []; % 顾客编号
        Gui3(g).wait = []; % 顾客等待时间
        Gui3(g).stay = []; % 顾客停留时间
        Gui3(g).S = -1 / C.lambdaS .* log(rand(1, 10000)); % 柜台服务时间序列
        Gui3(g).QuHistory = []; % 排队长度历史
    end
    output = Sim(C, Gui3, seed1); % 一次仿真结果
    seed1 = seed1 + 1;
    waitlist = [waitlist, mean([output.meanwait])]; % 平均等待时间列表
    staylist = [staylist, mean([output.meanstay])];
    Qulist = [Qulist, mean([output.meanQu])];
    maxlist = [maxlist, mean([output.maxQu])];
    BusyRatelist = [BusyRatelist, mean([output.BusyRate])];
end

% 输出点估计
fprintf('点估计结果：\n');
fprintf('平均等待时间的点估计: %.4f 分钟\n', mean(waitlist));
fprintf('平均逗留时间的点估计: %.4f 分钟\n', mean(staylist));
fprintf('平均排队长度的点估计: %.4f 人\n', mean(Qulist));
fprintf('最大排队长度的点估计: %.4f 人\n', mean(maxlist));
fprintf('柜台繁忙率的点估计: %.4f\n', mean(BusyRatelist));

% 输出方差点估计
fprintf('\n方差点估计结果：\n');
fprintf('平均等待时间的方差点估计: %.4f\n', var(waitlist));
fprintf('平均逗留时间的方差点估计: %.4f\n', var(staylist));
fprintf('平均排队长度的方差点估计: %.4f\n', var(Qulist));
fprintf('最大排队长度的方差点估计: %.4f\n', var(maxlist));
fprintf('柜台繁忙率的方差点估计: %.4f\n', var(BusyRatelist));

% 输出区间估计
fprintf('\n区间估计结果（置信水平95%%）：\n');
t_value = GetT975(i - 1, numData); % 使用 GetT975 函数获取 t 分位数
thetawait = [mean(waitlist) - t_value * sqrt(var(waitlist) / i), mean(waitlist) + t_value * sqrt(var(waitlist) / i)];
fprintf('平均等待时间的区间估计: [%.4f, %.4f] 分钟\n', thetawait);

thestay = [mean(staylist) - t_value * sqrt(var(staylist) / i), mean(staylist) + t_value * sqrt(var(staylist) / i)];
fprintf('平均逗留时间的区间估计: [%.4f, %.4f] 分钟\n', thestay);

thetaQulist = [mean(Qulist) - t_value * sqrt(var(Qulist) / i), mean(Qulist) + t_value * sqrt(var(Qulist) / i)];
fprintf('平均排队长度的区间估计: [%.4f, %.4f] 人\n', thetaQulist);

thetamaxQulist = [mean(maxlist) - t_value * sqrt(var(maxlist) / i), mean(maxlist) + t_value * sqrt(var(maxlist) / i)];
fprintf('最大排队长度的区间估计: [%.4f, %.4f] 人\n', thetamaxQulist);

thetaBusyRate = [mean(BusyRatelist) - t_value * sqrt(var(BusyRatelist) / i), mean(BusyRatelist) + t_value * sqrt(var(BusyRatelist) / i)];
fprintf('柜台繁忙率的区间估计: [%.4f, %.4f]\n', thetaBusyRate);