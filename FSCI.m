function fsci = FSCI(obj)
    % Calculates the Full-spectrum Index
    % cut the lenght of the led data
    [ wavelength_spd, spd] = reshapeWave(obj);
    % Interpolate to wavelength interval of 1nm from 380nm to 730nm
    numWave = 351;
    t=(380:1:730)';
    spd=interp1(wavelength_spd,spd,t,'spline');
    spd(isnan(spd)) = 0.0;
    % Normalize the relative spd so that the total power equals 1
    spd = spd/sum(spd); 
    %Equal energy cumulative spd
    EEcum=(1/numWave:1/numWave:1)';
    %Calculate FSI
    sumSqrDiff = zeros(1,numWave);
    for j=1:numWave
        cum = cumsum(spd); % A MatLab function for cumulative sums
        sqrDiff = (cum-EEcum).^2;
        sumSqrDiff(j)=sum(sqrDiff);
        spd=circshift(spd,1);
    end
    fsi=mean(sumSqrDiff);
    fsci=100-5.1*fsi;
end