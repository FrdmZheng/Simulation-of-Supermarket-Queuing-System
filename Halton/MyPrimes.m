function primes = MyPrimes(n)
    % ���� n ������
    primes = []; % ��������
    num = 2;
    while true
        % �ж��Ƿ�Ϊ����
        isPrime = true;
        for divisor = 2:sqrt(num)
            if mod(num, divisor) == 0
                isPrime = false;
                break;
            end
        end
        % ��ӵ������б�
        if isPrime
            primes = [primes, num];
        end
        % ���������б���Ϊ�������
        if length(primes) >= n
            break
        end
        num = num + 1;
    end
end