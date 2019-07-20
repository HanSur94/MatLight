function [x,f] = gauss_distribution3(amp, peak, FWHM, min, max, steps)

FWHM = FWHM * 1e-9 ;
x = linspace(min, max, steps) * 1e-9;
f = amp * exp( -((x - peak * 1e-9).^2) / ( FWHM ^2) );
end