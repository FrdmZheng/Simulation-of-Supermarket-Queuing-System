% ��ʼ��
C.N = 5; % ��̨����
C.lambdaA = 5; % �˿͵����/min��
C.lambdaG = 0.1; % �˿͹�����/min��
C.lambdaS = 1.0;  % ����ʱ�䣨��/min��

% �����������ʱ����������ʱ�䡢ÿ����̨���˷���ʱ��
Arrin = -1 / C.lambdaA .* log(rand(1, 1000)); % ����ʱ��������
Carral = cumsum(Arrin); % ����ʱ��
Ncus = find(Carral<180, 1, 'last'); % 3h�ڵ���Ĺ˿���
Goumai = -1 / C.lambdaG .* log(rand(1, 1000)); % ÿλ�˿͹����ʱ������
ArrTime = Carral + Goumai; % ÿλ�˿͵����̨��ʱ��
Arr = [1:1000; sort(ArrTime)]; % �������̨��ʱ�̸��˿ͱ��
Arr = Arr(:, 1:Ncus); % ��Сʱ�ڵ����̨�Ĺ˿͵ı���Լ�����ʱ��

% ��ʼ����̨״̬
for g = 1:C.N
    Gui(g).Qu = 0; % �Ŷ�����Ϊ0
    Gui(g).Bu = 0; % ���У�����0����æ1��
    Gui(g).Arrivaltime = []; % �˿͵���ʱ��
    Gui(g).Leavetime = []; % �˿��뿪ʱ��
    Gui(g).cus = []; % �˿ͱ��
    Gui(g).wait = []; % �˿͵ȴ�ʱ��
    Gui(g).stay = []; % �˿�ͣ��ʱ��
    Gui(g).S = -1 / C.lambdaS .* log(rand(1, 400)); % ��̨����ʱ������
    Gui(g).QuHistory = []; % �Ŷӳ�����ʷ
end

%main
Event = [Arr; 0 * ones(1, Ncus); 0 * ones(1, Ncus)]; % �¼����ϣ��˿ͱ�ţ��¼�ʱ�䣻�¼����ͣ�0Ϊ���1Ϊ�뿪������̨�ţ�
t = 0; % ��ʼʱ��
while true
    % �����¼��������˳�ѭ��
    if isempty(Event)
        break
    end
    % ���¼���������ʱ������
    [~, sortindices] = sort(Event(2, :));
    Event = Event(:, sortindices);
    
    % �������ȷ������¼�
    t = Event(2, 1); % ����ʱ��
    % �����¼�
    if Event(3, 1) == 0
        % �ж�ǰ���ĸ���̨
        Bindices = find([Gui.Bu] == 0);
        if isempty(Bindices)
            minValue = min([Gui.Qu]);
            minIndices = find([Gui.Qu] == minValue);
            randomIndex = randi(numel(minIndices));
            index = minIndices(randomIndex);
        else
            BindicesSize = length(Bindices); % ���й�̨�����С
            chosen = ceil(rand() * BindicesSize); % ���ѡ��Ŀ��й�̨
            index = Bindices(chosen);
        end
        % �����¼�
        Gui(index).cus = [Gui(index).cus, Event(1, 1)]; % ��¼�˿ͱ��
        Gui(index).Arrivaltime = [Gui(index).Arrivaltime, t]; % ��¼����ʱ��
        if Gui(index).Bu == 0 % ����ʱ����̨����
            Gui(index).Bu = 1; % ���Ĺ�̨Ϊ��æ
            Gui(index).Leavetime = [Gui(index).Leavetime, t + Gui(index).S(1)]; % ��¼�뿪ʱ��
            Event = [Event, [Event(1, 1); t + Gui(index).S(1); 1; index]]; % �����뿪�¼�
            Gui(index).wait = [Gui(index).wait, 0]; % ��¼�ȴ�ʱ��
            Gui(index).stay = [Gui(index).stay, Gui(index).S(1)]; % ��¼ͣ��ʱ��
            Gui(index).S(:, 1) = []; % ɾ���Ѿ��ù��ķ���ʱ�������
            Gui(index).QuHistory = [Gui(index).QuHistory, Gui(index).Qu]; % �Ŷӳ�����ʷ
        else % ����ʱ����̨������
            Gui(index).Qu = Gui(index).Qu + 1; % �Ŷӳ��ȼ�һ
            Gui(index).QuHistory = [Gui(index).QuHistory, Gui(index).Qu]; % �Ŷӳ�����ʷ
        end
    % �뿪�¼�
    else
        index = Event(4, 1); % �뿪�¼�����Ӧ�Ĺ�̨
        if Gui(index).Qu == 0 % ������û���Ŷ�
            Gui(index).Bu = 0; % ��̨��Ϊ����
        else % �����������Ŷ�
            Gui(index).Qu = Gui(index).Qu - 1; % �Ŷӳ��ȼ�һ
            cus = Gui(index).cus(1 + find(Gui(index).cus == Event(1, 1))); % �����ܷ���Ĺ˿�
            Gui(index).Leavetime = [Gui(index).Leavetime, t + Gui(index).S(1)]; % ��¼�뿪ʱ��
            Event = [Event, [cus; t + Gui(index).S(1); 1; index]]; % �����뿪�¼�
            Gui(index).wait = [Gui(index).wait, t - Gui(index).Arrivaltime(1 + find(Gui(index).cus == Event(1, 1)))]; % ��¼�ȴ�ʱ��
            Gui(index).stay = [Gui(index).stay, Gui(index).S(1) + t - Gui(index).Arrivaltime(1 + find(Gui(index).cus == Event(1, 1)))]; % ��¼ͣ��ʱ��
            Gui(index).S(:, 1) = []; % ɾ���Ѿ��ù��ķ���ʱ�������
        end
    end

    Event(:, 1) = []; % ����������¼�ɾ��
end
% ����ÿ����̨������
for g = 1:C.N
    Gui(g).meanwait = mean(Gui(g).wait); % ƽ���ȴ�ʱ��
    Gui(g).meanstay = mean(Gui(g).stay); % ƽ��ͣ��ʱ��
    Gui(g).BusyRate = (Gui(g).meanstay - Gui(g).meanwait) * length(Gui(g).QuHistory) / max(Gui(g).Leavetime); % ��æ��
    Gui(g).meanQu = mean(Gui(g).QuHistory); % ƽ���Ŷӳ���
    Gui(g).maxQu = max(Gui(g).QuHistory); % ����Ŷӳ���
end
