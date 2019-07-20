function [x,f] = gauss_distribution(amp, peak, FWHM)

FWHM = FWHM * 1e-9;

x = ( peak - 150 ):0.1:( peak + 150 );
x = x * 1e-9;

g1 = ( x - peak * 1e-9) .^ 2;
g2 = 2 * FWHM ^ 2;
f = amp * exp( -g1 / g2 );

end