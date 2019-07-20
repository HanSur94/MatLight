

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This script calculates chromaticity coordinates, CCT, CRI, GAI, and FSCI
%for a .  To use other sources, just
%replace the spd matrix with the values for the other source.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the led Data
obj = led2;

% cut the lenght of the led data
[ wavelength_spd, spd] = reshapeWave(obj);

% plot for debugging
plot(wavelength_spd, spd);

% get the CIE31 data
CIE31Table = getCIE31();
wavelength = CIE31Table(:,1);
xbar = CIE31Table(:,2);
ybar = CIE31Table(:,3);
zbar = CIE31Table(:,4);

% get The spectral reflectance data of 14 color test samples for CRI
TCS = getTCS();

% Data for isotemperature lines needed for calculating correlated color temperature

% The following provides a table of isotemperature lines for use with the Robertson Method
% (Robertson, 1968) to interpolate isotemperature lines from the CIE 1960 UCS.
% The spacing of the isotemp lines is very small (1 1/MK) so very little
% interpolation is actually needed for determining CCT. The latest (2002)
% recommended values for the physical constants determining blackbody
% radiation spectra are used

% dwave = wavelength(2)-wavelength(1); % wavelength increment = 1 nm
% 
% ubar = (2/3)*xbar;
% vbar = ybar;
% wbar = -0.5*xbar + (3/2)*ybar + 0.5*zbar;
% 
% % 2002 CODATA recommended values
% h = 6.6260693e-34;
% c = 299792458;
% k = 1.3806505e-23;
% c1 = 2*pi*h*c^2;
% c2 = h*c/k;
% 
% MrecpK = [0.01 1:600]; % mega reciprical Kelvin values of isotemperature lines
% T = 1./(MrecpK*1e-6);
% for i = 1:length(T)
%     spdref = c1 * (1e-9*wavelength).^-5 ./ (exp(c2./(T(i).* 1e-9*wavelength)) - 1);
%     spdref = spdref/max(spdref);
%     wave = wavelength*1e-9;
%     
%     % Equations from Wyszecki and Sitles, Color Science, 2nd ed. 1982, page
%     % 226 and 227
%     U = sum(spdref.*ubar);
%     V = sum(spdref.*vbar);
%     W = sum(spdref.*wbar);
%     R = U+V+W;
%     u(i) = U/R;
%     v(i) = V/R;
%     
%     Uprime = c1*c2*(T(i))^-2*sum(wave.^-6.*ubar.*exp(c2./(wave.*T(i))).*(exp(c2./(wave.*(T(i))))-1).^-2)*dwave;
%     Vprime = sum(c1*c2*T(i)^-2*wave.^-6.*vbar.*exp(c2./(wave.*T(i))).*(exp(c2./(wave.*(T(i))))-1).^-2)*dwave;
%     Wprime = sum(c1*c2*T(i)^-2*wave.^-6.*wbar.*exp(c2./(wave.*T(i))).*(exp(c2./(wave.*(T(i))))-1).^-2)*dwave;
%     Rprime = Uprime+Vprime+Wprime;
%     
%     sl(i) = (Vprime*R-V*Rprime)/(Uprime*R-U*Rprime);
%     m(i) = -1/sl(i);
% end
% ut = u;
% vt = v;
% tt = m;
% isoTempLinesTable = [T' u' v' m'];
% %save isoTempLinesNewestFine.txt isoTempLinesTable -ascii; % Optionally save file
% 
% % Second, calculate Correlated Color Temperature (CCT), Tc
% 
% %load ('isoTempLinesNewestFine.mat', 'T', 'ut', 'vt', 'tt'); % If read from previously saved file

% Interpolate CIE functions to spd increments
xbar = interp1(wavelength,xbar,wavelength_spd);
xbar(isnan(xbar)) = 0.0;
ybar = interp1(wavelength,ybar,wavelength_spd);
ybar(isnan(ybar)) = 0.0;
zbar = interp1(wavelength,zbar,wavelength_spd);
zbar(isnan(zbar)) = 0.0;

% get color chromaticity coordinates
[x, y, u, v] = chromaticityCoords(obj);

Tc = CCT(obj);
disp(Tc);

cri = CRI(obj);
disp(cri);

% % Third, calculate the Color Rendering Indices (CRI and its 14 indices)
% % Calculate Reference Source Spectrum, spdref.
% if (Tc < 5000)
%     c1 = 3.7418e-16;
%     c2 = 1.4388e-2;
%     spdref = c1 * (1e-9*wavelength_spd).^-5 ./ (exp(c2./(Tc.* 1e-9*wavelength_spd)) - 1);
% else
%     if (Tc <= 25000)
%         wavelength = DSPD(:,1);
%         S0 = DSPD(:,2);
%         S1 = DSPD(:,3);
%         S2 = DSPD(:,4);
%         
%         %load('DSPD','wavelength','S0','S1','S2');
%         if (Tc <= 7000)
%             xd = -4.6070e9 / Tc.^3 + 2.9678e6 / Tc.^2 + 0.09911e3 / Tc + 0.244063;
%         else
%             xd = -2.0064e9 / Tc.^3 + 1.9018e6 / Tc.^2 + 0.24748e3 / Tc + 0.237040;
%         end
%         yd = -3.000*xd*xd + 2.870*xd - 0.275;
%         M1 = (-1.3515 - 1.7703*xd + 5.9114*yd) / (0.0241 + 0.2562*xd - 0.7341*yd);
%         M2 = (0.0300 - 31.4424*xd + 30.0717*yd) / (0.0241 + 0.2562*xd - 0.7341*yd);
%         spdref = S0 + M1*S1 + M2*S2;
%         spdref = spdref / ( max(spdref) ) * 1.2;
%         plot(wavelength,spdref);
%         spdref = interp1(wavelength,spdref,wavelength_spd);
%         spdref(isnan(spdref)) = 0.0;
%     else
%         R = -1;
%         return
%     end
% end

% Interpolate TCS values from 5 nm to spd nm increments
% TCS_1 = zeros(length(wavelength_spd),14);
% for i = 1:14
%     TCS_1(:,i) = interp1(TCS(:,1),TCS(:,i+1),wavelength_spd,'linear',0);
% end
% 
% % Calculate u, v chromaticity coordinates of samples under test illuminant, uk, vk and
% % reference illuminant, ur, vr.
% uki = zeros(1,14);
% vki = zeros(1,14);
% uri = zeros(1,14);
% vri = zeros(1,14);
% X = trapz(wavelength_spd,spd .* xbar);
% Y = trapz(wavelength_spd,spd .* ybar);
% Z = trapz(wavelength_spd,spd .* zbar);
% Yknormal = 100 / Y;
% Yk = Y*Yknormal;
% uk = 4*X/(X+15*Y+3*Z);
% vk = 6*Y/(X+15*Y+3*Z);
% X = trapz(wavelength_spd,spdref .* xbar);
% Y = trapz(wavelength_spd,spdref .* ybar);
% Z = trapz(wavelength_spd,spdref .* zbar);
% Yrnormal = 100 / Y;
% Yr = Y*Yrnormal;
% ur = 4*X/(X+15*Y+3*Z);
% vr = 6*Y/(X+15*Y+3*Z);
% for i = 1:14
%     X = trapz(wavelength_spd,spd .* TCS_1(:,i) .* xbar);
%     Y = trapz(wavelength_spd,spd .* TCS_1(:,i) .* ybar);
%     Z = trapz(wavelength_spd,spd .* TCS_1(:,i) .* zbar);
%     Yki(i) = Y(i)*Yknormal;
%     uki(i) = 4*X/(X+15*Y+3*Z);
%     vki(i) = 6*Y/(X+15*Y+3*Z);
%     X = trapz(wavelength_spd,spdref .* TCS_1(:,i) .* xbar);
%     Y = trapz(wavelength_spd,spdref .* TCS_1(:,i) .* ybar);
%     Z = trapz(wavelength_spd,spdref .* TCS_1(:,i) .* zbar);
%     Yri(i) = Y(i)*Yrnormal;
%     uri(i) = 4*X/(X+15*Y+3*Z);
%     vri(i) = 6*Y/(X+15*Y+3*Z);
% end
% % Check tolorence for reference illuminant
% DC = sqrt((uk-ur).^2 + (vk-vr).^2);
% 
% % Apply adaptive (perceived) color shift.
% ck = (4 - uk - 10*vk) / vk;
% dk = (1.708*vk + 0.404 - 1.481*uk) / vk;
% cr = (4 - ur - 10*vr) / vr;
% dr = (1.708*vr + 0.404 - 1.481*ur) / vr;
% 
% for i = 1:14
%     cki = (4 - uki(i) - 10*vki(i)) / vki(i);
%     dki = (1.708*vki(i) + 0.404 - 1.481*uki(i)) / vki(i);
%     ukip(i) = (10.872 + 0.404*cr/ck*cki - 4*dr/dk*dki) / (16.518 + 1.481*cr/ck*cki - dr/dk*dki);
%     vkip(i) = 5.520 / (16.518 + 1.481*cr/ck*cki - dr/dk*dki);
% end
% 
% %  Transformation into 1964 Uniform space coordinates.
% for i = 1:14
%     Wstarr(i) = 25*Yri(i).^.333333 - 17;
%     Ustarr(i) = 13*Wstarr(i)*(uri(i) - ur);
%     Vstarr(i) = 13*Wstarr(i)*(vri(i) - vr);
%     
%     Wstark(i) = 25*Yki(i).^.333333 - 17;
%     Ustark(i) = 13*Wstark(i)*(ukip(i) - ur); % after applying the adaptive color shift, u'k = ur
%     Vstark(i) = 13*Wstark(i)*(vkip(i) - vr); % after applying the adaptive color shift, v'k = vr
% end
% 
% % Determination of resultant color shift, delta E.
% deltaE = zeros(1,14);
% R = zeros(1,14);
% for i = 1:14
%     deltaE(i) = sqrt((Ustarr(i) - Ustark(i)).^2 + (Vstarr(i) - Vstark(i)).^2 + (Wstarr(i) - Wstark(i)).^2);
%     R(i) = 100 - 4.6*deltaE(i);
% end
% Ra = sum(R(1:8))/8;
% fprintf(1,'CRIra = %.1f\n',Ra);

% % fourth, calculate the gamut area formed by the 8 CIE standard color samples
% ukii=[uki(:,1:8),uki(1)];
% vkii=1.5*[vki(:,1:8),vki(1)];
% Ga=polyarea(ukii,vkii);
% % Normalize gamut area to equal energy source
% Ga=Ga/0.00728468*100;
% fprintf(1,'Gamut Area Index = %.1f\n',Ga);
gA = gamutArea(obj);
disp(gA);
fsci = FSCI(obj);
disp(fsci);

% % Fifth, calculate the FSI (full spectrum index)
% % Calculates the Full-spectrum Index
% 
% % Interpolate to wavelength interval of 1nm from 380nm to 730nm
% numWave = 351;
% t=(380:1:730)';
% spd=interp1(wavelength_spd,spd,t,'spline');
% spd(isnan(spd)) = 0.0;
% spd = spd/sum(spd); % Normalize the relative spd so that the total power equals 1
% %Equal energy cumulative spd
% EEcum=(1/numWave:1/numWave:1)';
% %Calculate FSI
% 
% for j=1:numWave
%     cum = cumsum(spd); % A MatLab function for cumulative sums
%     sqrDiff = (cum-EEcum).^2;
%     sumSqrDiff(j)=sum(sqrDiff);
%     spd=circshift(spd,1);
% end
% fsi=mean(sumSqrDiff);
% fsci=100-5.1*fsi;
% fprintf(1,'FSCI = %.3f\n',fsci);
