%% Close everything
close all

%% Start the webcam
%cam = webcam(2);

%% take a snapshot
%img = snapshot(cam);

%% Clean up of the camera
%clear cam

%% load Imapge
tic;
[ img ] = imread('spectrum3_1.png');

%% get r,g,b values

r = img(:,:,1);
g = img(:,:,2);
b = img(:,:,3);
w = r+g+b;

%% average rgb Values
r = mean(r) ;
g = mean(g) ;
b = mean(b);
w = mean(w);

%% normalize values
max_w = max( w );
r = r / max_w;
g = g / max_w;
b = b / max_w;
w = w / max_w;

%% using only visible light
dataLenght = size(w,2);
wavelen = linspace(380, 780, dataLenght);

%% Plot rgb Values
figure;
subplot(3,2,1);
area(wavelen, r, 'FaceColor', 'r');
xlim([wavelen(1,1),wavelen(1, end)]); ylim([0,1]);
title('Red');
xlabel('Wavlenght in [nm]');
ylabel('Normalized Intensity');

subplot(3,2,2);
area(wavelen, g, 'FaceColor', 'g');
xlim([wavelen(1,1),wavelen(1, end)]); ylim([0,1]);
title('Green');
xlabel('Wavlenght in [nm]');
ylabel('Normalized Intensity');

subplot(3,2,3);
area(wavelen, b, 'FaceColor', 'b');
xlim([wavelen(1,1),wavelen(1, end)]); ylim([0,1]);
title('Blue');
xlabel('Wavlenght in [nm]');
ylabel('Normalized Intensity');


%% Plot colorful spectrum
subplot(3,2,4);
rgbLenghtCorr = dataLenght * 0.9;
vis_spec_start = 380;
vis_spec_end = 680;
hold on;
xlim([wavelen(1,1),wavelen(1, end)]); ylim([0,1]);

for k = 1:1:dataLenght

    % use black color for UV Light
    if ( wavelen(1,k) <vis_spec_start )
        bar( wavelen( 1, k ), w( 1, k ) , 'FaceColor', [0 0 0] , 'EdgeColor',  'none');
    end
    % use black color for infrared
    if ( wavelen(1,k) > vis_spec_end )
        bar( wavelen( 1, k ), w( 1, k ) , 'FaceColor', [0 0 0] , 'EdgeColor',  'none');
    end
    % define color for 
    if (wavelen(1,k) >= vis_spec_start  && wavelen(1,k) <= vis_spec_end)
       % rgbColor = hsv2rgb( ( (dataLenght - k) - 380  ) / rgbLenghtCorr, 1, 1);
        bar( wavelen( 1, k ), w( 1, k ) , 'FaceColor', [1 1 1], 'EdgeColor',  'none');
    end
    
end

% Plot black line
plot(wavelen, w, 'black');
hold off
title('Spectrum')
xlabel('Wavlenght in [nm]');
ylabel('Normalized Intensity');
toc;

%%  show the image
subplot(3,2, [ 5 6 ]);
imshow(img);
wavelen = wavelen * 1e-9;

