function [lambda, int] = reshapeWave(obj)
    obj.lambda = obj.lambda * 1e9;
    lambda = 380:10:780;
    int = 1:1:41;
    for i = 1:1:41
        l = round(median(find(round(obj.lambda) == lambda(1,i))));
        int(1,i) = obj.int(1,l);
    end
end