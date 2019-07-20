function [Tc] = CCT(obj)
    % get the CIE31 data
    CIE31Table = getCIE31();
    wavelength = CIE31Table(:,1);
    xbar = CIE31Table(:,2);
    ybar = CIE31Table(:,3);
    zbar = CIE31Table(:,4);
    % Data for isotemperature lines needed for calculating correlated color temperature
    % The following provides a table of isotemperature lines for use with the Robertson Method
    % (Robertson, 1968) to interpolate isotemperature lines from the CIE 1960 UCS.
    % The spacing of the isotemp lines is very small (1 1/MK) so very little
    % interpolation is actually needed for determining CCT. The latest (2002)
    % recommended values for the physical constants determining blackbody
    % radiation spectra are used
    dwave = wavelength(2)-wavelength(1); % wavelength increment = 1 nm
    ubar = (2/3)*xbar;
    vbar = ybar;
    wbar = -0.5*xbar + (3/2)*ybar + 0.5*zbar;
    % 2002 CODATA recommended values
    h = 6.6260693e-34;
    c = 299792458;
    k = 1.3806505e-23;
    c1 = 2*pi*h*c^2;
    c2 = h*c/k;
    % mega reciprical Kelvin values of isotemperature lines
    MrecpK = [0.01 1:600]; 
    T = 1./(MrecpK*1e-6);
    u = 1:1:length(T);
    v = 1:1:length(T);
    sl = 1:1:length(T);
    m = 1:1:length(T);
    for i = 1:length(T)
        spdref = c1 * (1e-9*wavelength).^-5 ./ (exp(c2./(T(i).* 1e-9*wavelength)) - 1);
        spdref = spdref/max(spdref);
        wave = wavelength*1e-9;
        % Equations from Wyszecki and Sitles, Color Science, 2nd ed. 1982, page
        % 226 and 227
        U = sum(spdref.*ubar);
        V = sum(spdref.*vbar);
        W = sum(spdref.*wbar);
        R = U+V+W;
        u(i) = U/R;
        v(i) = V/R;
        Uprime = c1*c2*(T(i))^-2*sum(wave.^-6.*ubar.*exp(c2./(wave.*T(i))).*(exp(c2./(wave.*(T(i))))-1).^-2)*dwave;
        Vprime = sum(c1*c2*T(i)^-2*wave.^-6.*vbar.*exp(c2./(wave.*T(i))).*(exp(c2./(wave.*(T(i))))-1).^-2)*dwave;
        Wprime = sum(c1*c2*T(i)^-2*wave.^-6.*wbar.*exp(c2./(wave.*T(i))).*(exp(c2./(wave.*(T(i))))-1).^-2)*dwave;
        Rprime = Uprime+Vprime+Wprime;
        sl(i) = (Vprime*R-V*Rprime)/(Uprime*R-U*Rprime);
        m(i) = -1/sl(i);
    end
    ut = u;
    vt = v;
    tt = m;
    % get the chromaticity coordinates for u and v 
    [~, ~, u, v] = chromaticityCoords(obj);
    % Find adjacent lines to (us, vs)
    n = length (T);
    index = 0;
    d1 = ((v-vt(1)) - tt(1)*(u-ut(1)))/sqrt(1+tt(1)*tt(1));
    for i=2:n
        d2 = ((v-vt(i)) - tt(i)*(u-ut(i)))/sqrt(1+tt(i)*tt(i));
        if (d1/d2 < 0)
            index = i;
            break;
        else
            d1 = d2;
        end
    end
    if index == 0
        Tc = 'Not able to calculate CCT, u, v coordinates outside range.';
        fprintf(1,'Not able to calculate CCT, u, v coordinates outside range.\n');
        return
    else
        % Calculate CCT by interpolation between isotemperature lines
        Tc = 1/(1/T(index-1)+d1/(d1-d2)*(1/T(index)-1/T(index-1)));
    end
end