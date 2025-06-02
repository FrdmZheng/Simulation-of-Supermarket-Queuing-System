function P0 = calculate_P0(ro, S)
    sum_part = 0;
    for j = 0:(S-1)
        sum_part = sum_part + ((S * ro)^j) / factorial(j);
    end
    second_part = ((S * ro)^S) / factorial(S) * (1 / (1 - ro));
    P0 = 1 / (sum_part + second_part);
end


function Pj = calculate_Ps(ro, S, j)
    % 首先计算 P0
    P0 = calculate_P0(ro, S);
    
    % 根据 j 的值计算 Pj
    if j > S
        Pj = (S^S * ro^j) / (S * factorial(S)) * P0;
    elseif j <= S
        Pj = ((S * ro)^j) / factorial(j) * P0;
    else
        error('j must be a positive integer');
    end
end



function Lq = calculate_Lq(ro, S,j)
    % 首先计算 P0
    P0 = calculate_P0(ro, S);
    
    % 计算 Pj 当 j = S 时的值
    Ps = calculate_Ps(ro, S, j)
    
    % 计算 Lq
    Lq = ro / ((1 - ro)^2) * Ps;
end


function Wq = calculate_Wq(ro, lambda, S,j)
    % 首先计算 P0
    P0 = calculate_P0(ro, S);
    % 计算 Pj 当 j = S 时的值
    Ps = calculate_Ps(ro, S, j);
    % 计算 Wq
    Wq = ro / (lambda * (1 - ro)^2) * Ps;
end

wq1=calculate_Wq(5/6, 5, 5,5)
wq2=calculate_Wq(5/6.5, 5, 5,5)
wq3=calculate_Wq(5/7, 5, 5,5)
wq4=calculate_Wq(5/7.5, 5, 5,5)
wq5=calculate_Wq(5/8, 5, 5,5)
