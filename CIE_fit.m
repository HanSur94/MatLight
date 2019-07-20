close all;
clear all;

%% define global min max values for the wavelenght
min_wav = 200;
max_wav = 900;

%% V lambda  function
% define v lambda function - photopic
[lambda, V] = gauss_distribution2(1, 555, 40, min_wav, max_wav);
% define v lambda function - scotopic
%[lambda, V] = gauss_distribution2(1 ,507, 40 ,100, 1000);

%% create black body radiation
% black body temprature in [K]
bb_temp = 2000;
% black body amplitude multiplier
bb_amp = 1;
% define black body radiation
[lambda, bb_rad] = bbrad( bb_temp, bb_amp, min_wav, max_wav);
% normalize the black body radiation
%bb_rad = bb_rad / max( bb_rad );

%% create led data
% led FWHM in [nm]
led_FWHM = 32;
% led peak wavelength in [nm]
led_peak_wav = 650;
% led intensity peak in [W]
led_amp = 10e-3;
% define spectral distribution of the led
[lambda, led_e] = gauss_distribution2(led_amp, led_peak_wav, led_FWHM, min_wav, max_wav);

%% try to create an white led
% white led blue light wavelenght peak in [nm]
w_led_blue_peak_wav = 440;
% white led blue light FWHM in [nm]
w_led_blue_FWHM = 10;
% white led blue light intensity peak in [W]
w_led_blue_amp = 1e-3;
% white led phos light wavelenght peak in [nm]
w_led_phos_peak_wav = 575;
% white led phos light FWHM in [nm]
w_led_phos_FWHM = 60;
% white led phos light intensity peak in [W]
w_led_phos_amp = 0.8e-3;
% create spectrum due to phosphore
[ lambda, w_1 ] = gauss_distribution2(w_led_phos_amp,...
    w_led_phos_peak_wav, w_led_phos_FWHM, min_wav, max_wav);
% create spectrum due to blue led
[ lambda, w_2 ] = gauss_distribution2(w_led_blue_amp,...
    w_led_blue_peak_wav, w_led_blue_FWHM, min_wav, max_wav);
% combine both spectra
w = w_1 + w_2;
clear w_1 w_2;

%% convert led Data
%choose dataset
%led_e = bb_rad;
led_e = w;
% photopic luminous coefficient in [lm/W]
K_m = 683.002;
% scotopic luminous coefficient in [lm/W]
%K_m = 1699;
led_v = led_e .* V *K_m ;

%% plot data
figure;
ylabels{1} ='relative spectral luminosity in [1 * nm^-1]';
ylabels{2} ='\Phi_e spectral radiant flux in [W * nm^-1]';
ylabels{3} ='\Phi_v spectral luminous flux in [lm * nm^-1]';
xlabel = 'wavelength \lambda in [m]';
[ax,hlines] = plotyyy( lambda, V, lambda, led_e, lambda, led_v, xlabel, ylabels );
legend(hlines, 'V(\lambda)', ' \Phi_e spectral power', '\Phi_v spectral luminous flux' );


%% print data
disp('Total luminous flux Led output in [lm]:');
disp( trapz( led_v ) );
disp('Peak of radiant flux in [lm]:');
disp( max( led_v ) );
disp('wavelength of peak radiant flux in [nm]:');
disp( lambda(find(led_v == max( led_v ))) * 1e9  );
disp('luminous efficiency in [lm/W]:');
disp(  trapz( led_v ) / trapz(led_e) );

%% create Led Data
clear led_e;
% led peak wavelength in [nm]
led_peak_wav_v = 500;
% led FWHM in [nm]
led_FWHM_v = 40;
% led intensity peak in [lm]
led_amp_v = 1;
% define spectral distribution of the led
%[lambda_v, led_v] = gauss_distribution2(led_amp_v, led_peak_wav_v, led_FWHM_v, 100,1000);

%% calc radiometric led values
led_e =  led_v  / K_m ./ V;

%% plot data
figure;
ylabels{1} ='V(\lambda) relative spectral luminosity in [1 * nm^-1]';
ylabels{2} ='Phi_e spectral radiant flux in [W * nm^-1]';
ylabels{3} ='\Phi_v spectral radiant flux in [lm * nm^-1]';
xlabel = 'wavelength \lambda in [m]';
[ax,hlines] = plotyyy( lambda, V, lambda, led_e, lambda, led_v, xlabel, ylabels );
legend(hlines, 'V(\lambda)', ' \Phi_e spectral power', '\Phi_v spectral luminous flux' );

%% print data
disp('Total radiant flux Led output in [W]:');
disp( trapz( led_e ) );
disp('Peak of radiant flux in [W]:');
disp( max( led_e ) );
disp('wavelength of peak radiant flux in [nm]:');
disp( lambda(find(led_e == max( led_e ))) * 1e9  );
disp('luminous efficiency in [lm/W]:');
disp(  trapz( led_v ) / trapz(led_e) );

%% conversion of the photometric data into CIE colour space
% get the CIE curves for rgb
[lambda, b_] = gauss_distribution2(0.32, 445, 30, min_wav, max_wav);
[lambda, g_] = gauss_distribution2(0.215,550, 35, min_wav, max_wav );
[lambda, r_1] = gauss_distribution2(0.35, 595,30, min_wav,max_wav );
[lambda, r_2] = gauss_distribution2(-0.09, 515,30, min_wav,max_wav );
r_ = r_1 +r_2;

%% multiply and integrate the spectral power distribution with the rgb

R = trapz( led_v/ max(led_v) .* r_ );
G = trapz( led_v/ max(led_v) .* g_ );
B = trapz( led_v/ max(led_v) .* b_ );
W = R + G + B;

r = R / W ; 
g = G / W ;
b = B / W ;

%% print data
disp('R:')
disp(r);
disp('G:')
disp(g);
disp('B:')
disp(b);

disp('R:')
disp(r * 255);
disp('G:')
disp(g * 255);
disp('B:')
disp(b * 255);






