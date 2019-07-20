%% clear 
clear all;
close all;
%% create the leds
mySim = lightSim(1,1000,1000);
led1 = led.led2(mySim, 'led1', 'W', 365, 20, 1e-3);
led2 = led.led2(mySim, 'led2', 'lm', 405, 50, 5e-3*A2Sr(120) );
led3 = led.led2(mySim, 'led3', 'lm', 466, 20, 220e-3*A2Sr(120) );
led4 = led.led2(mySim, 'led4', 'lm', 518, 50, 400e-3*A2Sr(120) );
led5 = led.led2(mySim, 'led5', 'lm', 575, 50, 400e-3*A2Sr(120) );
led6 = led.led2(mySim, 'led6', 'lm', 610, 40, 120e-3*A2Sr(120) );
led7 = led.led2(mySim, 'led7', 'lm', 660, 50, 16e-3*A2Sr(120) );
%% convert
%led2 = led.convertMode(led2, 'phot', 'no plot');
led3 = led.convertMode(led3, 'phot', 'no plot');
led4 = led.convertMode(led4, 'phot', 'no plot');
led5 = led.convertMode(led5, 'phot', 'no plot');
led6 = led.convertMode(led6, 'phot', 'no plot');
led7 = led.convertMode(led7, 'phot', 'no plot');
%% plot all
%led.plotLed('combine', led2, led3, led4, led5, led6, led7);
%% combine
resultLed = led.combine(  led3, led4, led5, led6, led7);
resultLed.name = 'resultLed';
% 
blackBody= blackBody(mySim, 'sun', 'W', 1, 6500);
%blackBody = led.convertMode(blackBody, 'phot', 'plot');
led.plotAll(blackBody);
%% plot result
led.plotAll(resultLed);
