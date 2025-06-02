numData = readmatrix('GetT975.xlsx'); % 读取t数值数据
beta = 0.2; % 相对精度需要满足的值

% 方案1
waitlist1 = []; % 初始化平均等待时间列表
Nlast1 = 1; Nnew1 = 5; % 初始化仿真次数
precision1 = beta + 1; % 使能循环
while precision1 >= beta % 若精度不达要求，则继续仿真
    for i = Nlast1:Nnew1
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
        output = Sim(C, Gui); % 一次仿真结果
        waitlist1 = [waitlist1, mean([output.meanwait])]; % 平均等待时间列表
    end
    Nlast1 = Nnew1 + 1; % 下一组实验从该次实验开始
    mean1 =  mean(waitlist1); % 均值
    var1 = var(waitlist1); % 方差
    precision1 = GetT975(Nnew1 - 1, numData) * var1 / sqrt(Nnew1) / mean1; % 相对精度
    theta1 = precision1 * mean1; % 区间半长
    mean1 = mean1; % 区间中点
    while true
        Nnew1 = Nnew1 + 1;
        t1 = GetT975(Nnew1 - 1, numData);
        if t1 * var1 / sqrt(Nnew1) / mean1 <= beta
            break; % 如果满足相对精度条件则停止，i为需要进行的所有仿真的次数
        end
    end
end
