function [lambda, int] = reshapeWave2(objlambda, objint)
    objlambda = objlambda * 1e9;
    lambda = 380:10:780;
    int = 1:1:41;
    
    for i = 1:1:41
        l = round(median(find(round(objlambda) == lambda(1,i))));
        int(1,i) = objint(1,l);
    end
    %plot(lambda, int);

end