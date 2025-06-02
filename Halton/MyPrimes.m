function primes = MyPrimes(n)
    % 生成 n 个质数
    primes = []; % 质数数组
    num = 2;
    while true
        % 判断是否为质数
        isPrime = true;
        for divisor = 2:sqrt(num)
            if mod(num, divisor) == 0
                isPrime = false;
                break;
            end
        end
        % 添加到质数列表
        if isPrime
            primes = [primes, num];
        end
        % 控制质数列表长度为所需个数
        if length(primes) >= n
            break
        end
        num = num + 1;
    end
end