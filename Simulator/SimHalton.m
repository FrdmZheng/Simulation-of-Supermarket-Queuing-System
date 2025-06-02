function [Gui, ihalton] = SimHalton(C, Gui, base, count)
% 输入样例

% C.N = 5; % 柜台数量
% C.lambdaA = 5; % 顾客到达（人/min）
% C.lambdaG = 0.1; % 顾客购买（人/min）
% C.lambdaS = 1;  % 服务时间（人/min）

% 初始化柜台状态
%for g = 1:C.N
%    Gui(g).Qu = 0; % 排队人数为0
%    Gui(g).Bu = 0; % 空闲（空闲0；繁忙1）
%    Gui(g).Arrivaltime = []; % 顾客到达时刻
%    Gui(g).Leavetime = []; % 顾客离开时刻
%    Gui(g).cus = []; % 顾客编号
%    Gui(g).wait = []; % 顾客等待时间
%    Gui(g).stay = []; % 顾客停留时间
%    Gui(g).S = -1 / C.lambdaS .* log(rand(1, 400)); % 柜台服务时间序列
%end

% 以第几个质数为基
% base = 1;
% 随机数序列开始取值的index
% count = 0；

% 获取halton随机数序列
realbase = MyPrimes(base);
realbase = realbase(base);
templst = MyHaltons([count + 2000, base]);
templst = templst(count + 1:count + 2000, base);
templst = templst'
% 生成随机到达时间间隔、购物时间、每个柜台结账服务时间
Arrin = -1 / C.lambdaA .* log(templst(1, 1:1000)); % 到达时间间隔序列
Carral = cumsum(Arrin); % 到达时刻
Ncus = find(Carral<180, 1, 'last'); % 3h内到达的顾客数
Goumai = -1 / C.lambdaG .* log(templst(1, 1001:2000)); % 每位顾客购买的时间序列
ArrTime = Carral + Goumai; % 每位顾客到达柜台的时间
Arr = [1:1000; sort(ArrTime)]; % 按到达柜台的时刻给顾客编号
Arr = Arr(:, 1:Ncus); % 三小时内到达柜台的顾客的编号以及到达时间

%main
Event = [Arr; 0 * ones(1, Ncus); 0 * ones(1, Ncus)]; % 事件集合（顾客编号；事件时间；事件类型（0为到达；1为离开）；柜台号）
t = 0; % 初始时刻
ihalton = count + 2001;
while true
    % 若无事件发生则退出循环
    if isempty(Event)
        break
    end
    % 将事件按发生的时间排序
    [~, sortindices] = sort(Event(2, :));
    Event = Event(:, sortindices);
    
    % 处理最先发生的事件
    t = Event(2, 1); % 更新时间
    % 到达事件
    if Event(3, 1) == 0
        % 判断前往哪个柜台
        Bindices = find([Gui.Bu] == 0);
        if isempty(Bindices)
            [~, index] = min([Gui.Qu]); % 排队长度最小
        else
            BindicesSize = length(Bindices); % 空闲柜台数组大小
            chosen = ceil(MyHalton(ihalton, realbase) * BindicesSize); % 随机选择的空闲柜台
            ihalton = ihalton + 1;
            index = Bindices(chosen);
        end
        % 处理事件
        Gui(index).cus = [Gui(index).cus, Event(1, 1)]; % 记录顾客标号
        Gui(index).Arrivaltime = [Gui(index).Arrivaltime, t]; % 记录到达时间
        if Gui(index).Bu == 0 % 到达时若柜台空闲
            Gui(index).Bu = 1; % 更改柜台为繁忙
            Gui(index).Leavetime = [Gui(index).Leavetime, t + Gui(index).S(1)]; % 记录离开时间
            Event = [Event, [Event(1, 1); t + Gui(index).S(1); 1; index]]; % 更新离开事件
            Gui(index).wait = [Gui(index).wait, 0]; % 记录等待时间
            Gui(index).stay = [Gui(index).stay, Gui(index).S(1)]; % 记录停留时间
            Gui(index).S(:, 1) = []; % 删除已经用过的服务时间随机数
            Gui(index).QuHistory = [Gui(index).QuHistory, Gui(index).Qu]; % 排队长度历史
        else % 到达时若柜台不空闲
            Gui(index).Qu = Gui(index).Qu + 1; % 排队长度加一
            Gui(index).QuHistory = [Gui(index).QuHistory, Gui(index).Qu]; % 排队长度历史
        end
    % 离开事件
    else
        index = Event(4, 1); % 离开事件所对应的柜台
        if Gui(index).Qu == 0 % 若后面没人排队
            Gui(index).Bu = 0; % 柜台改为空闲
        else % 若后面有人排队
            Gui(index).Qu = Gui(index).Qu - 1; % 排队长度减一
            cus = Gui(index).cus(1 + find(Gui(index).cus == Event(1, 1))); % 更新受服务的顾客
            Gui(index).Leavetime = [Gui(index).Leavetime, t + Gui(index).S(1)]; % 记录离开时间
            Event = [Event, [cus; t + Gui(index).S(1); 1; index]]; % 更新离开事件
            Gui(index).wait = [Gui(index).wait, t - Gui(index).Arrivaltime(1 + find(Gui(index).cus == Event(1, 1)))]; % 记录等待时间
            Gui(index).stay = [Gui(index).stay, Gui(index).S(1) + t - Gui(index).Arrivaltime(1 + find(Gui(index).cus == Event(1, 1)))]; % 记录停留时间
            Gui(index).S(:, 1) = []; % 删除已经用过的服务时间随机数
        end
    end

    Event(:, 1) = []; % 将处理过的事件删除
end

% 计算每个柜台的性能
for g = 1:C.N
    Gui(g).meanwait = mean(Gui(g).wait); % 平均等待时间
    Gui(g).meanstay = mean(Gui(g).stay); % 平均停留时间
    Gui(g).BusyRate = (Gui(g).meanstay - Gui(g).meanwait) * length(Gui(g).QuHistory) / max(Gui(g).Leavetime); % 繁忙率
    Gui(g).meanQu = mean(Gui(g).QuHistory); % 平均排队长度
    Gui(g).maxQu = max(Gui(g).QuHistory); % 最大排队长度
end


end