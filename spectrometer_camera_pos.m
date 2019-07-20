% in [mm]
lambda_min = 250e-6;   
lambda_max = 900e-6;

% in [lp/mm]
g = 1000;

% in [°]
O_min = asin( lambda_min * 1 * g ) / pi * 180;
O_max = asin(lambda_max * 1 * g) / pi * 180;

% in [m]
height_diff  = 1e-2;
lenght = height_diff / ( tan(O_max / 180 * pi)  - tan(O_min / 180 * pi));
a = tan(O_min / 180 * pi) * lenght;
b = tan(O_max / 180 * pi) * lenght;

