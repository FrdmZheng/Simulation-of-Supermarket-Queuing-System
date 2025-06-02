
numData = readmatrix('GetT975.xlsx'); % 读取t数值数据

% 方案1
beta = 0.2; % 相对精度需要满足的值
waitlist1 = []; % 初始化平均等待时间列表
% 循环仿真（5次，确定精度）
for i = 1:5
    % 初始化
    C.N = 5; % 柜台数量
    C.lambdaA = 5; % 顾客到达（人/min）
    C.lambdaG = 0.1; % 顾客购买（人/min）
    C.lambdaS = 1;  % 服务时间（人/min）
    % 初始化柜台状态
    for g = 1:C.N
        Gui(g).Qu = 0; % 排队人数为0
        Gui(g).Bu = 0; % 空闲（空闲0；繁忙1）
        Gui(g).Arrivaltime = []; % 顾客到达时刻
        Gui(g).Leavetime = []; % 顾客离开时刻
        Gui(g).cus = []; % 顾客编号
        Gui(g).wait = []; % 顾客等待时间
        Gui(g).stay = []; % 顾客停留时间
        Gui(g).S = -1 / C.lambdaS .* log(rand(1, 400)); % 柜台服务时间序列
        Gui(g).QuHistory = []; % 排队长度历史
    end
    output = Sim(C, Gui);
    waitlist1 = [waitlist1, mean([output.meanwait])];
end
mean11 = mean(waitlist1); % 5次循环样本均值
var11 = var(waitlist1); % 5次循环样本方差
t11 = 2.776; % alpha=0.05, P0=5（95%置信区间的t值）
precision11 = t11 * var11 / sqrt(5) / mean11; % 计算相对精度
if precision11 > beta
    i = 5;
    while true
        i = i + 1;
        t1i = GetT975(i - 1, numData);
        if t1i * var11 / sqrt(i) / mean11 <= beta
            break; % 如果满足相对精度条件则停止，i为需要进行的所有仿真的次数
        end
    end
    Ndiff1 = i - 5; % 剩下需要仿真的次数
    % 循环仿真（差值）
    for i = 1:Ndiff1
        % 初始化
        C.N = 5; % 柜台数量
        C.lambdaA = 5; % 顾客到达（人/min）
        C.lambdaG = 0.1; % 顾客购买（人/min）
        C.lambdaS = 1;  % 服务时间（人/min）
        % 初始化柜台状态
        for g = 1:C.N
            Gui(g).Qu = 0; % 排队人数为0
            Gui(g).Bu = 0; % 空闲（空闲0；繁忙1）
            Gui(g).Arrivaltime = []; % 顾客到达时刻
            Gui(g).Leavetime = []; % 顾客离开时刻
            Gui(g).cus = []; % 顾客编号
            Gui(g).wait = []; % 顾客等待时间
            Gui(g).stay = []; % 顾客停留时间
            Gui(g).S = -1 / C.lambdaS .* log(rand(1, 400)); % 柜台服务时间序列
        end
        output = Sim(C, Gui);
        waitlist1 = [waitlist1, mean([output.meanwait])];
    end
    mean12 = mean(waitlist1); % 总循环样本均值
    var12 = var(waitlist1); % 总循环样本方差
    t12 = GetT975(i - 1, numData); % alpha=0.05, P0=Inf（95%置信区间的t值）
    precision12 = t12 * var12 / sqrt(i) / mean12; % 计算相对精度
    theta1 = precision12 * mean12; % 区间半长
    mean1 = mean12; % 区间中点    
elseif precision11 <= beta
    theta1 = precision11 * mean11; % 区间半长
    mean1 = mean11; % 区间中点
end     
