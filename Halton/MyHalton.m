function r = MyHalton(i, base)
f = 1;
r = 0;
while i > 0
    f = f / base;
    r = r + f * mod(i, base);
    i = floor(i / base);
end