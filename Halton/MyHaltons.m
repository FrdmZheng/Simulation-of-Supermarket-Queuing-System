function mat = MyHaltons(shp)
mat = []; % 初始化Halton矩阵
baselst = MyPrimes(shp(2)); % 生成素数列表
for m = 1:shp(2)
    lst = [];
    for n = 1:shp(1)
        lst = [lst; MyHalton(n, baselst(m))];
    end
    mat = [mat, lst];
end




