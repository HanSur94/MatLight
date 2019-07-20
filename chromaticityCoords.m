function [x, y, u, v] = chromaticityCoords(obj)
    % cut the lenght of the led data
    [ wavelength_spd, spd] = reshapeWave(obj);
    % get the CIE31 data
    CIE31Table = getCIE31();
    wavelength = CIE31Table(:,1);
    xbar = CIE31Table(:,2);
    ybar = CIE31Table(:,3);
    zbar = CIE31Table(:,4);
    % Interpolate CIE functions to spd increments
    xbar = interp1(wavelength,xbar,wavelength_spd);
    xbar(isnan(xbar)) = 0.0;
    ybar = interp1(wavelength,ybar,wavelength_spd);
    ybar(isnan(ybar)) = 0.0;
    zbar = interp1(wavelength,zbar,wavelength_spd);
    zbar(isnan(zbar)) = 0.0;
    % Calculate Chromaticity Coordinates
    X = trapz(wavelength_spd,spd.*xbar);
    Y = trapz(wavelength_spd,spd.*ybar);
    Z = trapz(wavelength_spd,spd.*zbar);
    x = X/(X+Y+Z);
    y = Y/(X+Y+Z);
    u = 4*x/(-2*x+12*y+3);
    v = 6*y/(-2*x+12*y+3);
end