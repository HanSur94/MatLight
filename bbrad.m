function [lambda, intensity] = bbrad( temp, min, max, steps)

lambda  = linspace(min, max, steps);
lambda = lambda * 1e-9;

k = 1.38e-23;
h = 6.62e-34;
c = 3e8;
 
p1 = 1 * ( (h * c) / ( pi * k * temp ) )^4;
p2 = lambda.^5;
p3 = 1;
p4 = exp( (h * c) ./ ( lambda * k * temp )) - 1;
intensity = p1 ./ p2 * p3 ./ p4;

end