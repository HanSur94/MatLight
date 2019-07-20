function gA = gamutArea(obj)
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
    % get The spectral reflectance data of 14 color test samples for CRI
    TCS = getTCS();
    % get the color Temp
    Tc = obj.cct;
    if ( strcmp(Tc,...
            'Not able to calculate CCT, u, v coordinates outside range.') == 1)
        gA = Tc;
        return
    end
    % Interpolate TCS values from 5 nm to spd nm increments
    TCS_1 = zeros(length(wavelength_spd),14);
    for i = 1:14
        TCS_1(:,i) = interp1(TCS(:,1),TCS(:,i+1),wavelength_spd,'linear',0);
    end
    % Third, calculate the Color Rendering Indices (CRI and its 14 indices)
    % Calculate Reference Source Spectrum, spdref.
    if (Tc < 5000)
        c1 = 3.7418e-16;
        c2 = 1.4388e-2;
        spdref = c1 * (1e-9*wavelength_spd).^-5 ./ (exp(c2./(Tc.* 1e-9*wavelength_spd)) - 1);
    else
        if (Tc <= 25000)
            DSPD = getDSPD();
            wavelength = DSPD(:,1);
            S0 = DSPD(:,2);
            S1 = DSPD(:,3);
            S2 = DSPD(:,4);

            %load('DSPD','wavelength','S0','S1','S2');
            if (Tc <= 7000)
                xd = -4.6070e9 / Tc.^3 + 2.9678e6 / Tc.^2 + 0.09911e3 / Tc + 0.244063;
            else
                xd = -2.0064e9 / Tc.^3 + 1.9018e6 / Tc.^2 + 0.24748e3 / Tc + 0.237040;
            end
            yd = -3.000*xd*xd + 2.870*xd - 0.275;
            M1 = (-1.3515 - 1.7703*xd + 5.9114*yd) / (0.0241 + 0.2562*xd - 0.7341*yd);
            M2 = (0.0300 - 31.4424*xd + 30.0717*yd) / (0.0241 + 0.2562*xd - 0.7341*yd);
            spdref = S0 + M1*S1 + M2*S2;
            spdref = spdref / ( max(spdref) ) * 1.2;
            spdref = interp1(wavelength,spdref,wavelength_spd);
            spdref(isnan(spdref)) = 0.0;
        else
            R = -1;
            return
        end
    end
    % Calculate u, v chromaticity coordinates of samples under test illuminant, uk, vk and
    % reference illuminant, ur, vr.
    uki = zeros(1,14);
    vki = zeros(1,14);
    uri = zeros(1,14);
    vri = zeros(1,14);
    X = trapz(wavelength_spd,spd .* xbar);
    Y = trapz(wavelength_spd,spd .* ybar);
    Z = trapz(wavelength_spd,spd .* zbar);
    Yknormal = 100 / Y;
    Yk = Y*Yknormal;
    uk = 4*X/(X+15*Y+3*Z);
    vk = 6*Y/(X+15*Y+3*Z);
    X = trapz(wavelength_spd,spdref .* xbar);
    Y = trapz(wavelength_spd,spdref .* ybar);
    Z = trapz(wavelength_spd,spdref .* zbar);
    Yrnormal = 100 / Y;
    Yr = Y*Yrnormal;
    ur = 4*X/(X+15*Y+3*Z);
    vr = 6*Y/(X+15*Y+3*Z);
    Yki = zeros(1,14);
    Yri = zeros(1,14);
    for i = 1:14
        X = trapz(wavelength_spd,spd .* TCS_1(:,i) .* xbar);
        Y = trapz(wavelength_spd,spd .* TCS_1(:,i) .* ybar);
        Z = trapz(wavelength_spd,spd .* TCS_1(:,i) .* zbar);
        Yki(i) = Y(i)*Yknormal;
        uki(i) = 4*X/(X+15*Y+3*Z);
        vki(i) = 6*Y/(X+15*Y+3*Z);
        X = trapz(wavelength_spd,spdref .* TCS_1(:,i) .* xbar);
        Y = trapz(wavelength_spd,spdref .* TCS_1(:,i) .* ybar);
        Z = trapz(wavelength_spd,spdref .* TCS_1(:,i) .* zbar);
        Yri(i) = Y(i)*Yrnormal;
        uri(i) = 4*X/(X+15*Y+3*Z);
        vri(i) = 6*Y/(X+15*Y+3*Z);
    end
    % Check tolorence for reference illuminant
    %DC = sqrt((uk-ur).^2 + (vk-vr).^2);
    % Apply adaptive (perceived) color shift.
    ck = (4 - uk - 10*vk) / vk;
    dk = (1.708*vk + 0.404 - 1.481*uk) / vk;
    cr = (4 - ur - 10*vr) / vr;
    dr = (1.708*vr + 0.404 - 1.481*ur) / vr;
    ukip = zeros(1,14);
    vkip = zeros(1,14);
    for i = 1:14
        cki = (4 - uki(i) - 10*vki(i)) / vki(i);
        dki = (1.708*vki(i) + 0.404 - 1.481*uki(i)) / vki(i);
        ukip(i) = (10.872 + 0.404*cr/ck*cki - 4*dr/dk*dki) / (16.518 + 1.481*cr/ck*cki - dr/dk*dki);
        vkip(i) = 5.520 / (16.518 + 1.481*cr/ck*cki - dr/dk*dki);
    end
    % fourth, calculate the gamut area formed by the 8 CIE standard color samples
    ukii=[uki(:,1:8),uki(1)];
    vkii=1.5*[vki(:,1:8),vki(1)];
    Ga=polyarea(ukii,vkii);
    % Normalize gamut area to equal energy source
    Ga=Ga/0.00728468*100*1e30;
    gA = Ga;
end