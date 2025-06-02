numData = readmatrix('GetT975.xlsx'); % 读取t数值数据
beta = 0.1; % 相对精度需要满足的值
rng("default");

% 方案1
seed1 = 1;
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
        rng(seed1, "twister");
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
        output = Sim(C, Gui, seed1); % 一次仿真结果
        seed1 = seed1 + 1;
        waitlist1 = [waitlist1, mean([output.meanwait])]; % 平均等待时间列表
    end
    Nlast1 = Nnew1 + 1; % 下一组实验从该次实验开始
    mean1 =  mean(waitlist1); % 均值
    var1 = var(waitlist1); % 方差
    precision1 = GetT975(Nnew1 - 1, numData) *  sqrt(var1 /Nnew1) / mean1; % 相对精度
    theta1 = precision1 * mean1; % 区间半长
    mean1 = mean1; % 区间中点
    while true
        Nnew1 = Nnew1 + 1;
        t1 = GetT975(Nnew1 - 1, numData);
        if t1 *  sqrt(var1 /Nnew1) / mean1 <= beta
            break; % 如果满足相对精度条件则停止，i为需要进行的所有仿真的次数
        end
    end
end
RangeY1=[mean1-GetT975(i - 1, numData)*sqrt(var1/i),mean1+GetT975(i - 1, numData)*sqrt(var1/i)]; %Y1性能的95%置信区间
fprintf('Y1的期望的95%% 置信区间 (RangeY1): [%f, %f]\n',RangeY1(1), RangeY1(2));
fprintf('Y1的期望的95%% 置信区间半长为：%f\n',theta1);

% 方案2I (四个柜台)
seed2 = 10000;
waitlist2 = []; % 初始化平均等待时间列表
for j = 1:i
        % 初始化
        C.N = 10; % 柜台数量
        C.lambdaA = 5; % 顾客到达（人/min）
        C.lambdaG = 0.1; % 顾客购买（人/min）
        C.lambdaS = 5/10;  % 服务时间（人/min）
        % 初始化柜台状态
        rng(seed2, "twister");
        for g = 1:C.N
            Gui2(g).Qu = 0; % 排队人数为0
            Gui2(g).Bu = 0; % 空闲（空闲0；繁忙1）
            Gui2(g).Arrivaltime = []; % 顾客到达时刻
            Gui2(g).Leavetime = []; % 顾客离开时刻
            Gui2(g).cus = []; % 顾客编号
            Gui2(g).wait = []; % 顾客等待时间
            Gui2(g).stay = []; % 顾客停留时间
            Gui2(g).S = -1 / C.lambdaS .* log(rand(1, 1000)); % 柜台服务时间序列
            Gui2(g).QuHistory = []; % 排队长度历史
        end
        output2 = Sim(C, Gui2, seed2); % 一次仿真结果
        seed2 = seed2 + 1;
        waitlist2 = [waitlist2, mean([output2.meanwait])]; % 平均等待时间列表
end
var2 = var(waitlist2); % 方案二（2I）方差
mean2 =  mean(waitlist2); % 方案二（2I）均值
precision2 = GetT975(i - 1, numData) *  sqrt(var2 / i) / mean2; % 方案二（2I）相对精度
theta2 = precision2 * mean2; % 方案二区间半长

EY1Y2I=mean1-mean2; %1与2I性能之差的期望的点估计
VY1Y2I=var1/i+var2/i; %1与2I性能之差的方差的点估计
fY1Y2I=round((var1/i+var2/i)^2/((var1/i)^2/(i+1)+(var2/i)^2/(i+1))-2); %1与2I性能之差的自由度
RangeY1Y2I=[EY1Y2I-GetT975(i - 1, numData)*sqrt(VY1Y2I),EY1Y2I+GetT975(i - 1, numData)*sqrt(VY1Y2I)]; %1与2I性能之差的95%置信区间
% 输出结果
fprintf('1与2I之差的期望点估计 (EY1Y2I): %f\n', EY1Y2I);
fprintf('1与2I之差的方差的点估计 (VY1Y2I): %f\n', VY1Y2I);
fprintf('自由度 (fY1Y2I): %d\n', fY1Y2I);
fprintf('1与2I之差的期望的95%% 置信区间 (RangeY1Y2I): [%f, %f]\n', RangeY1Y2I(1), RangeY1Y2I(2));




% 方案2C (四个柜台)
seed1 = 1;
waitlist3 = []; % 初始化平均等待时间列表
for k = 1:i
        % 初始化
        C.N = 10; % 柜台数量
        C.lambdaA = 5; % 顾客到达（人/min）
        C.lambdaG = 0.1; % 顾客购买（人/min）
        C.lambdaS = 5/10;  % 服务时间（人/min）
        % 初始化柜台状态
        rng(seed1, "twister");
        for g = 1:C.N
            Gui3(g).Qu = 0; % 排队人数为0
            Gui3(g).Bu = 0; % 空闲（空闲0；繁忙1）
            Gui3(g).Arrivaltime = []; % 顾客到达时刻
            Gui3(g).Leavetime = []; % 顾客离开时刻
            Gui3(g).cus = []; % 顾客编号
            Gui3(g).wait = []; % 顾客等待时间
            Gui3(g).stay = []; % 顾客停留时间
            Gui3(g).S = -1 / C.lambdaS .* log(rand(1, 1000)); % 柜台服务时间序列
            Gui3(g).QuHistory = []; % 排队长度历史
        end
        output3 = Sim(C, Gui3, seed1); % 一次仿真结果
        seed1 = seed1 + 1;
        waitlist3 = [waitlist3, mean([output3.meanwait])]; % 平均等待时间列表
end

Y1Y2C = waitlist1 - waitlist3;
VY1Y2C = var(Y1Y2C);
EY1Y2C = mean(Y1Y2C);
fY1Y2C = i - 1;
RangeY1Y2C = [EY1Y2C - GetT975(fY1Y2C, numData) * sqrt(VY1Y2C/(i)), EY1Y2C + GetT975(fY1Y2C, numData) * sqrt(VY1Y2C/(i))];

fprintf('1与2C之差的期望点估计 (EY1Y2C): %f\n', EY1Y2C);
fprintf('1与2C之差的方差的点估计 (VY1Y2C): %f\n', VY1Y2C/i);
fprintf('自由度 (fY1Y2C): %d\n', fY1Y2C);
fprintf('1与2C之差的期望的95%% 置信区间 (RangeY1Y2C): [%f, %f]\n', RangeY1Y2C(1), RangeY1Y2C(2));
