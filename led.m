classdef led < lightSim
    % Description:
    % Led class is a subclass of the lightSim class.
    % The Led class mimics the behaiviour of an single simple led radiator.
    % The Simulation is based in the the simulation superclass, which you
    % have to define before.
    %
    % For creating an Led, simply create a lughtSim class and then the led
    % subclass using the defined cunctructor. A Led is the superclass for
    % a white Led and a Laserdiode and the blackbody radiator.
    %
    % Showing the led class structure:
    %       
    %     lightSim > led > whiteLed, laserdiode, black body radiator
    %               
    properties
        % name of the optical radiator: string
        name
        % mode of the optical radiator: string: use 'W' or 'lm'
        mode
        % peak wavelength in [nm]
        peak
        % full width half maximum in [nm]
        fwhm
        % spectral intensity distribution [W/m] or [lm/m] depending on depending on the selected "mode"
        int
        % wavelength in [m]
        lambda
        % peak amplitude value in [W/ nm] or [lm/ nm] depending on the selected "mode"
        amp
        % electrical sim components
        eSim
    end
    % Dependent Properties
    properties (Dependent)
        % integrated intensity of the Led in [W] or [lm]
        intInt
        % efficacy of the radiator in [lm/W]
        efficacy
       % color temprature of the radiator in [K]
        cct
        % color rendering index 
        cri
        % gamut Area
        gA
        % full spectrum color index
        fsci
        % CIE31 x, y color coordinates
        xyCoords
        % CIE31 u, v color coordinates
        uvCoords
    end
    % non-public method
    methods
        %% calculating the luminous efficay
        function eff = get.efficacy( obj )
            % decide what mode the led has
            if( strcmp(obj.mode,'W') == 1 )
                converted = obj.int .* obj.VPhot * obj.KmPhot;
                eff = trapz(converted) / trapz(obj.int);
            elseif (strcmp(obj.mode,'lm') == 1)
                converted = obj.int ./ obj.VPhot / obj.KmPhot ;
                eff = trapz(obj.int) / trapz(converted);
            end
        end
        %% calculating the xy color coordinates
        function XY = get.xyCoords( obj )
            XY = [0,0];
            [XY(1,1), XY(1,2), ~, ~] = chromaticityCoords(obj);
        end
        %% calculating the uv color coordinates
        function UV = get.uvCoords( obj )
            UV = [0,0];
            [ ~, ~, UV(1,1), UV(1,2)] = chromaticityCoords(obj);
        end
        %% calculating the color temprature from spectral data
        function colorTemp = get.cct( obj )
            colorTemp = CCT(obj);
        end
        %% calculating the fsci
        function fSCI = get.fsci( obj )
            fSCI = FSCI(obj);
            fSCI = abs(fSCI);
        end
        %% calculating the gamut Area
        function gamutarea = get.gA( obj )
            gamutarea = gamutArea(obj);
        end
        %% calculating the color temprature from spectral data
        function colorRenderingIndex = get.cri( obj )
            if ( strcmp(obj.cct,...
                    'Not able to calculate CCT, u, v coordinates outside range.') == 1)
                colorRenderingIndex = obj.cct;
            else
                colorRenderingIndex = CRI(obj);
            end
        end
        %% calculate full/integratet Intensity
        function fint = get.intInt(obj)
            fint = trapz(obj.int);
        end
    end
    % public methods
    methods (Static)
        %% electrical Simulation constructor
        function obj = elecSim(lightSim, led, maxCurrent, maxVoltage, current, voltage)
            % ELECSIM( lightSim, led, maxCurrent, maxVoltage, current, voltage )
            %
            % obj = ELECSIM( lightSim, led, maxCurrent, maxVoltage, current, voltage )
            %
            % obj = ELECSIM( lightSim, led, empty )
            %
            % PARAMETERS:
            % lightSim: lightSim: the superclass simulation
            % led: led: led to modify
            % maxCurrent: double: maximum nominal current for full output
            % power
            % maxVoltage: double: voltage at maximum nominal current
            % current: double: used current
            % voltage: double: voltage level at used current
            % empty: string: use 'empty' to clear the electrical Simulation
            % and reset the optical properties
            %
            % OUTPUT:
            % obj: led: modified object of the class led
            %
            % DESCRIPTION:
            % This function is a constructor for the an electrical
            % simulation and is optional for any led class. Based on the
            % electrical properties, this function will modify the optical
            % properties in terms of the output power.
            
            % check for numbers of input arguments
            switch (nargin)
                % if 3 input arguments
                case 3
                    % check if string empty is ok
                    if ( strcmp('empty', maxCurrent) == 1 )
                        % check if we have to recalculate the intensity
                        if ( isempty(led.eSim) == 1 )
                            % return led and empty eSim 
                            obj = led;
                            obj.eSim = [ ];
                        else
                            % recalculate the intensity
                            eSim.Phi = led.intInt * led.eSim.maxCurrent / led.eSim.current;
                            % return led and empty eSim
                            obj = led.led2(lightSim, led.name, led.mode, led.peak, led.fwhm, eSim.Phi);
                            obj.eSim = [ ];
                        end
                    else
                        error('String empty is not "empty"!');
                    end
                % if 6 input arguments
                case 6
                    % set input parameters
                    eSim.maxCurrent = maxCurrent;
                    eSim.maxVoltage = maxVoltage;
                    eSim.current = current;
                    eSim.voltage = voltage;
                    eSim.n = led.intInt / ( maxCurrent * maxVoltage);
                    % check if we have to recalculate the intensity
                    if (isempty(led.eSim) == 1)
                        eSim.n = led.intInt / ( maxCurrent * maxVoltage);
                        eSim.Phi = led.intInt * current / maxCurrent;
                    else
                        % recalculate the intensity
                        oldIntInt = led.intInt * led.eSim.maxCurrent / led.eSim.current;
                        % update the intensity based on electrical
                        % characteristics
                        eSim.n = oldIntInt / ( maxCurrent * maxVoltage);
                        eSim.Phi = oldIntInt * current / maxCurrent;
                    end
                    obj = led.led2(lightSim, led.name, led.mode, led.peak, led.fwhm, eSim.Phi);
                    obj.eSim = eSim;
                otherwise
                    error('Wrong number of input parameters. Use 3 or 6 Input Parameters!');
            end
        end
        %% create led constructor
        function obj = led(lightSim, name, mode, peak, fwhm, amp)
            % LED( lightSim, name, mode, peak, fwhm, amp )
            % obj = LED( lightSim, name, mode, peak, fwhm, amp )
            %
            % PARAMETERS:
            % lightSim: lightSim: the superclass simulation
            % name: string: name of the led
            % mode: string: mode of the led in 'W' or 'lm'
            % peak: double: peak wavelenght of the led
            % fwhm: double: full width half maximum of the led spectral
            % distribution
            % amp: double: amplitude value at peak wavelenght
            %
            % OUTPUT:
            % obj: led: object of the class led
            %
            % DESCRIPTION:
            % This function is a constructor and will create a new object
            % of the led class with all needed properties. The amplitude
            % Value "amp" is in Units of [W/ nm] or [lm/ nm]!
            %
            % You may want to use the second constructor led.led2, since
            % the most datasheet give only information about the Intensity
            % with Units [W], [lm] or similar. 
            obj = obj@lightSim(lightSim.minWave, lightSim.maxWave, lightSim.steps);
            % check if name and mode are strings
            if ( ischar([ name, mode ]) == 1 )
                % set led props
                obj.name = name;
                obj.mode = mode;
                obj.peak = peak;
                obj.fwhm = fwhm;
                obj.amp = amp;
                [ obj.lambda, obj.int ] = gauss_distribution2(amp, peak, fwhm, obj.minWave , obj.maxWave, obj.steps);
            else
                error('led name and mode are not strings');
            end
        end
        %% create a new led constructor based on the integrated intensity
        function obj = led2(lightSim, name, mode, peak, fwhm, intInt)
            % LED2( lightSim, name, mode, peak, fwhm, intInt )
            % obj = LED2( lightSim, name, mode, peak, fwhm, intInt )
            %
            % PARAMETERS:
            % lightSim: lightSim: the superclass simulation
            % name: string: name of the led
            % mode: string: mode of the led in 'W' or 'lm'
            % peak: double: peak wavelenght of the led
            % fwhm: double: full width half maximum of the led spectral
            % distribution
            % intInt: double: integrated amplitude of the spectral
            % distribution
            %
            % OUTPUT:
            % obj: led: object of the class led
            %
            % DESCRIPTION:
            % This function is a constructor and will create a new object
            % of the led class with all needed properties. The amplitude
            % Value "inInt" is in Units of [W] or [lm]!
            % create led with amplitude 1
            [ ~, obj.int] = gauss_distribution2(1, peak, fwhm, lightSim.minWave, lightSim.maxWave, lightSim.steps);
            % calculate integrated intensity
            int = trapz(obj.int);
            % create the led
            obj = led(lightSim, name, mode, peak, fwhm, intInt / int);
        end
        %% plot led data
        function plotLed(plotMode, varargin )
            % PLOTLED( plotMode, varargin )
            %
            % PARAMETERS:
            % plotMode: string: 'seperate' or 'combine'
            % varargin: led: objects of class led or subclass
            %
            % DESCRIPTION:
            % This function will plot the spectral
            % distribution of the optical radiator. If the plotMode =
            % 'seperate' then the function will output a new plot for each
            % object. If the plotMode = 'combine' then the function will
            % output all object data into one single plot.
            if (strcmp(plotMode, 'seperate') == 1)
                for i = 1:1:size(varargin,2)
                    figure;
                    title([ 'Spectral distribution of: ', varargin{1,i}.name ]);
                    xlabel( 'Wavelength \lambda in [m]' );
                    % set grid
                    grid on;
                    grid minor;
                    %  set axis limits
                    plot(varargin{1,i}.lambda, varargin{1,i}.int);
                    xlim([varargin{1,i}.minWave * 1e-9, varargin{1,i}.maxWave * 1e-9]);
                    ylim([0  max(varargin{1,i}.int) ]);
                    if (strcmp(varargin{1,i}.mode, 'W') == 1)
                        ylabel( 'Spectral distribution \Phi_{e\lambda} in [W^1 * m^-1]' );
                    end
                    if (strcmp(varargin{1,i}.mode, 'lm') == 1)
                        ylabel( 'Spectral distribution \Phi_{v\lambda} in [lm^1 * m^-1]' );
                    end
                end
            elseif (strcmp(plotMode, 'combine') == 1)
                legendNames = cell(1,size(varargin,2));
                figure;
                title( 'Spectral distribution of: ');
                hold on;
                %  set axis limits
                xlim([varargin{1,1}.minWave * 1e-9, varargin{1,1}.maxWave * 1e-9]);
                % find maximum of all
                maximum = 0;
                % plot
                for i = 1:1:size(varargin,2)
                    % find maximum
                    if(max(varargin{1,i}.int) > maximum)
                        maximum = max(varargin{1,i}.int);
                    end
                    plot(varargin{1,i}.lambda, varargin{1,i}.int);
                    xlabel( 'Wavelength \lambda in [m]' );
                    % set grid
                    grid on;
                    grid minor;
                    if (strcmp(varargin{1,i}.mode, 'W') == 1)
                        ylabel( 'Spectral distribution \Phi_{e\lambda} in [W^1 * m^-1]' );
                    end
                    if (strcmp(varargin{1,i}.mode, 'lm') == 1)
                        ylabel( 'Spectral distribution \Phi_{v\lambda} in [lm^1 * m^-1]' );
                    end
                    legendNames{1,i} = varargin{1,i}.name;
                end
                hold off;
                ylim([0  maximum]);
                legend(legendNames);
            end
        end
        %% plot xy coordinates in CIE31 colormap
        function plotXYColor( varargin )
            % PLOTXYCOLOR( varargin )
            %
            % NOTE: Edit function, so it will break if no xy coordinates
            % are not available
            %
            % PARAMETERS:
            % varargin: led: objects of class led or subclass
            %
            % DESCRIPTION:
            % This function will plot the x and y color coordinated in the
            % CIE31 chromaticy plane.
            
            % create figure
            figure;
            % plot CIE31 map
            plotChromaticity();
            % get title
            title('CIE31 colormap and LED x,y coordinates');
            hold on;
            % iterate through varargins
            for i = 1:1:nargin
                % do scatter plot
                scatter(varargin{1,i}.xyCoords(1,1), varargin{1,i}.xyCoords(1,2));
                % do text
                text(varargin{1,i}.xyCoords(1,1), varargin{1,i}.xyCoords(1,2),...
                    varargin{1,i}.name,'VerticalAlignment','bottom');
            end
            hold off;
        end
        %% print led data
        function printLed( varargin )
            % PRINTLED( varargin )
            %
            % PARAMETERS:
            % varargin: led: objects of class led or subclass
            %
            % DESCRIPTION: 
            % This function will display the undependent properties of the
            % led class or any subclass. It will display following
            % properties: name, mode, peak wavelenght, full width half
            % maximum and peak amplitude.
            for i = 1:1:size(varargin,2)
                fprintf( 'Name: %s\nMode: %s\n Peak Wavelenght: %d nm\n FWHM: %d nm\n Amplitude: %d %s\n\n',...
                    varargin{1,i}.name, varargin{1,i}.mode, varargin{1,i}.peak,...
                    varargin{1,i}.fwhm, varargin{1,i}.amp ,varargin{1,i}.mode);
            end
        end
        %% convert from either radiometric or photometric
        function obj = convertMode( obj, conv_mode, plot )
            % CONVERTMODE( obj, conv_mode, plot )
            % obj = CONVERTMODE( obj, conv_mode, plot )
            %
            % PARAMETERS:
            % obj: led: objects of class led or led subclass
            % conv_mode: string:  'phot' or 'scot'
            % plot: string: 'no plot' or 'plot'
            %
            % OUTPUT:
            % obj: led: object of class led or led subclass
            %
            % DESCRIPTION: 
            % This function will convert the mode of any led object or
            % subclass object from 'W' to 'lm' or reverse.
            % Additionally we need to set the conversion mode 'phot' for
            % Photometric (for daytime), or 'scot' for Scotopic (for nighttime).
            % If you want to see a plot with the result, the set 'plot' for
            % plot. Otherwise set 'no plot' for plot.
            % The function uses two functions: led.rad2phot(obj,
            % conv_mode) and led.phot2rad(obj, conv_mode).            
            if (strcmp(plot, 'plot') == 1)
                int_before = obj.int;
                mode_before = obj.mode;
            end
            % only possible if the existing LED is radiometric mode
            if (strcmp(obj.mode, 'W') == 1)
                obj = led.rad2phot( obj, conv_mode );
                % only possible if the existing LED is radiometric mode
            elseif (strcmp(obj.mode, 'lm') == 1)
                obj = led.phot2rad( obj, conv_mode);
            end
            % update amplitude
            obj.amp = max(obj.int);
            % plot result if neededs
            if (strcmp(plot, 'plot') == 1)
                int_after = obj.int;
                ylabels{1} ='V(\lambda) relative spectral luminosity in [1 * m^-1]';
                ylabels{2} ='\Phi_{e\lambda} spectral radiant distribution in [W * m^-1]';
                ylabels{3} ='\Phi_{v\lambda} spectral luminous distribution in [lm * m^-1]';
                xlabel = 'wavelength \lambda in [m]';
                [~, hlines] = plotyyy( obj.lambda, obj.VPhot, obj.lambda, int_before, obj.lambda, int_after, xlabel, ylabels );
                legend(hlines, 'V(\lambda)', ' \Phi_{e\lambda} spectral power distribution', '\Phi_{v\lambda} spectral luminous flux distribution' );
                title(['Conversion of ', obj.name, ' from ', mode_before, ' to ', obj.mode]);
            end
        end
        %% convert from radionetric to photometric
        function obj = rad2phot(obj, conv_mode )
            % RAD2PHOT( obj, conv_mode )
            % obj = RAD2PHOT( obj, conv_mode )
            %
            % PARAMETERS:
            % obj: led: object of class led or led subclass
            % conv_mode: string: 'phot' or 'scot'
            %
            % OUTPUT:
            % obj: led: object of class led or led subclass
            %
            % DESCRIPTION: 
            % This function will convert the mode of any led object or led
            % subclass object from 'W' to 'lm'. Additionally we
            % need to set the conversion mode 'phot' for Photometric (for
            % daytime), or 'scot' for Scotopic (for nighttime).
            if ( strcmp(conv_mode, 'phot') == 1)
                obj.int = obj.int .* obj.VPhot * obj.KmPhot ;
            end
            if ( strcmp(conv_mode, 'scot') == 1)
                obj.int = obj.int .* obj.VScot * obj.KmScot ;
            end
            obj.mode = 'lm';
        end
        %% convert from photometric to radiometric
        function obj = phot2rad( obj, conv_mode )
            % PHOT2RAD( obj, conv_mode )
            % obj = PHOT2RAD( obj, conv_mode )
            %
            % PARAMETERS:
            % obj: object of class led or led subclass
            % conv_mode: 'phot' or 'scot'
            %
            % OUTPUT:
            % obj: object of class led or led subclass
            %
            % DESCRIPTION: 
            % This function will convert the mode of any led object or led
            % subclass object from 'lm' to 'W'. Additionally we
            % need to set the conversion mode 'phot' for Photometric (for
            % daytime), or 'scot' for Scotopic (for nighttime).
            % check wich conversion mode we want scotopic or photopic.
            if (strcmp(conv_mode, 'phot') == 1)
                obj.int = obj.int ./ obj.VPhot / obj.KmPhot;
            end
            if (strcmp(conv_mode, 'scot') == 1)
                obj.int = obj.int ./ obj.VScot / obj.KmScot ;
            end
            obj.mode = 'W';
        end
        %% function for combining light sources
        function obj = combine( varargin )
            % COMBINE( varargin )
            % obj = COMBINE( varargin )
            %
            % PARAMETERS:
            % varargin: led: led or led sublcass
            %
            % OUTPUT:
            % obj: led: object of class led or led subclass
            %
            % DESCRIPTION:
            % This function will combine as many led or led subclass
            % objects you will pass in as parameter. It will sum up all
            % spectral distributions from the objects. If the objects are
            % not in the same mode, the will be converted to the mode of
            % the first one. The first led you pass will be the reference
            % for the mode parameter. The amp and peak parameter will ...
            for  i = 2:1:size(varargin,2)
                % check if the leds have the same mode
                if ( strcmp( varargin{1,i}.mode, varargin{1,i}.mode) == 1 )
                    varargin{1,1}.int = varargin{1,1}.int + varargin{1,i}.int;
                else
                    % log for user
                    disp(['need to convert: ', varargin{1,i}.name, ' from ',...
                        varargin{1,i}.mode, ' to ', varargin{1,i}.mode]);
                    % convert led mode
                    varargin{1,i} = led.convertMode( varargin{1,i}, 'phot', 'noPlot');
                    % add intensities
                    varargin{1,1}.int = varargin{1,1}.int + varargin{1,i}.int;
                end
                % add names
                newName = strcat(varargin{1,1}.name, ' + ', varargin{1,i}.name);
                % update name
                varargin{1,1}.name = newName;
            end
            % update amp
            varargin{1,1}.amp = max( varargin{1,1}.int );
            % update peak
            varargin{1,1}.peak = varargin{1,1}.lambda(1,(...
                find(varargin{1,1}.int == varargin{1,1}.amp ) ))...
                * 1e9;
            % return combined led object
            obj = varargin{1,1};
        end
        %% function to import spectral Data
        function [nls, obj] = importLED( name, mode, fwhm, int, lambda)
            % IMPORTLED( name, mode, peak, fwhm, amp, int, lambda )
            % obj = IMPORTLED( name, mode, peak, fwhm, amp, int, lambda )
            %
            % PARAMETERS:
            % name: string: name of the data
            % mode: string: 'W' or 'lm'
            % peak: double: peak wavelength of the led
            % fwhm: double: full width half maximum of the led
            % amp:  double: amplitudeat peak wavelength
            % int:  double: rowvector: spectral distribution data
            % lambda: double: rowevector:  wavelength
            %
            % OUTPUT:
            % obj: led: object of class led or led subclass
            %
            % DESCRIPTION:
            % This function will import custom data of the spectral
            % distribution from an led. The function will output a new led
            % object of the class led as well as a new lightSim class. All
            % calculations are based on the new lightSim class parameters.
            
            % create a new lightSim and copy it to the 'base' workspace
            nls = lightSim( min(lambda), max(lambda), size(lambda,2));
            % create a new led object
            obj = led(nls,name, mode, nls.minWave*1e9, fwhm, 1);
            % assign the 
            obj.int = int;
            obj.lambda = lambda;
            % get the peak wavelenght % amplitude
            obj.amp =  max(obj.int);
            [~, idx] = max(obj.int);
            obj.peak = obj.lambda(1,idx);
        end
        %% plot cct, gA, cri, fsci in one plot
        function plotLedInfo( varargin )
            % PLOTLEDINFO( varargin )
            %
            % PARAMETERS:
            % varargin: led: objects of class led or led subclass
            %
            % DESCRIPTION:
            % This function will show different led parameters in a
            % graphical overview via a plot. Parameters include: cct = color
            % temprature, cri = color rendering index, gA = gamutArea, fsci
            % = full spectrum color index
            
            % set bar values
            bigBarWidth = 10;
            smallBarWidth = bigBarWidth / 3;
            % set colors
            lightGrey = [0.75, 0.75, 0.75];
            darkGrey = [0.5, 0.5, 0.5];
            % define minimum & maximum Values
            maxVal = 160;
            minVal = -160;
            % create Text
            effTxt = 'Efficacy';
            criTxt = 'Color Rendering Index';
            gATxt = 'Gamut Area';
            fsciTxt = 'Full Spectrum Color Index';
            % iterate through all objects
            for i = 1:1:size(varargin, 2)
                % start figure
                figure;
                % define Title
                title(['Led Color Information of ', varargin{1,i}.name]);
                % execute only if cct is a number
                if ( strcmp(varargin{1,i}.cct,'Not able to calculate CCT, u, v coordinates outside range.') == 0 )
                    % get led parameters and assign them to new variables
                    % to save a lot of computational resources!
                    gA = varargin{1,i}.gA;
                    cri = varargin{1,i}.cri;
                    fsci = varargin{1,i}.fsci;
                    efficacy = varargin{1,i}.efficacy;
                    % set the axes limits
                    if ( efficacy > maxVal)
                        xlim([minVal efficacy]);
                        ylim([minVal maxVal]);
                    else
                        xlim([minVal maxVal]);
                        ylim([minVal maxVal]);
                    end
                    hold on;
                    % plot for the efficacy
                    rectangle('Position', [0,0,150,bigBarWidth], 'FaceColor', lightGrey, 'EdgeColor', darkGrey);
                    rectangle('Position', [0,0,efficacy,smallBarWidth], 'FaceColor', 'black', 'EdgeColor', 'black');
                    rectangle('Position', [0,smallBarWidth,efficacy,smallBarWidth], 'FaceColor', 'white', 'EdgeColor', 'black');
                    rectangle('Position', [0,smallBarWidth*2,efficacy,smallBarWidth], 'FaceColor', 'black', 'EdgeColor', 'black');
                    % plot for the cri
                    rectangle('Position', [0,0,bigBarWidth,150], 'FaceColor', lightGrey, 'EdgeColor', darkGrey);
                    rectangle('Position', [0,0,smallBarWidth,cri], 'FaceColor', 'red', 'EdgeColor', 'red');
                    rectangle('Position', [smallBarWidth,0,smallBarWidth,cri], 'FaceColor', 'green', 'EdgeColor', 'green');
                    rectangle('Position', [smallBarWidth*2,0,smallBarWidth,cri], 'FaceColor', 'blue', 'EdgeColor', 'blue');
                     % plot for the gA
                    rectangle('Position', [-150,0,150,bigBarWidth], 'FaceColor', lightGrey, 'EdgeColor', darkGrey);
                    rectangle('Position', [-gA,0,gA,smallBarWidth], 'FaceColor', 'red', 'EdgeColor', 'red');
                    rectangle('Position', [-gA,smallBarWidth,gA,smallBarWidth], 'FaceColor', 'green', 'EdgeColor', 'green');
                    rectangle('Position', [-gA,smallBarWidth*2,gA,smallBarWidth], 'FaceColor', 'blue', 'EdgeColor', 'blue');
                    % plot for the fsci
                    rectangle('Position', [0,-150,bigBarWidth,150], 'FaceColor', lightGrey, 'EdgeColor', darkGrey);
                    rectangle('Position', [0,-fsci,smallBarWidth,fsci], 'FaceColor', 'red', 'EdgeColor', 'red');
                    rectangle('Position', [smallBarWidth,-fsci,smallBarWidth,fsci], 'FaceColor', 'green', 'EdgeColor', 'green');
                    rectangle('Position', [smallBarWidth*2,-fsci,smallBarWidth,fsci], 'FaceColor', 'blue', 'EdgeColor', 'blue');
                    % polt text to axes
                    text(160, bigBarWidth * 2, effTxt,'HorizontalAlignment','right');
                    text(bigBarWidth * 2, 160, criTxt,'HorizontalAlignment','left');
                    text(-160, bigBarWidth * 2, gATxt,'HorizontalAlignment','left');
                    text(bigBarWidth * 2, -160, fsciTxt,'HorizontalAlignment','left');
                    % redefine Text
                    effTxt = ['Efficacy in [lm/W]: ', num2str(efficacy)];
                    criTxt = ['CRI: (', num2str(cri), ')'];
                    gATxt =  ['GA: (', num2str(gA), ')'];
                    fsciTxt = ['FSCI: (', num2str(fsci), ')'];
                    % plot led informations
                    headLine = text(minVal+10, 120, varargin{1,i}.name,'HorizontalAlignment','left');
                    headLine.FontSize = 20;
                    text(minVal+10, 100, effTxt,'HorizontalAlignment','left');
                    text(minVal+10, 90, criTxt,'HorizontalAlignment','left');
                    text(minVal+10, 80, gATxt,'HorizontalAlignment','left');
                    text(minVal+10, 70, fsciTxt,'HorizontalAlignment','left');
                    hold off;
                    % set axes settings
                    ax = gca;
                    ax.XAxisLocation = 'origin';
                    ax.YAxisLocation = 'origin';
                    ax.XMinorTick = 'on';
                    ax.YMinorTick = 'on';
                    ax.TickDir = 'out';
                else
                    disp('Not able to plot Led infos, u, v coordinates outside range.');
                end
            end
        end
        %% plot all led informations
         function plotAll(varargin)
%             args = varargin;
%             disp(args);
%             % PLOTALL( varargin )
%             %
%             % PARAMETERS:
%             % varargin: led: objects of class led or led subclass
%             %
%             % DESCRIPTION:
%             % This function will use all plot functions: plotXYColor( varargin ),
%             % plotLed('combine', varargin ), plotLedInfo( varargin )
%             led.plotXYColor(args);
%             led.plotLed('combine', varargin);
%             led.plotLedInfo(varargin); 
         end
        %% calculate RGB values for defined sbit number
        function rgb = XY2RGB(obj, bit)
            % XY2RGB( obj, bit )
            % rgb = XY2RGB( obj, bit )
            %
            % PARAMETERS:
            % obj: led: objects of class led or led subclass
            % bit: integer: bit number, has to be n*2!
            %
            % OUTPUT:
            % rgb: 1x3 double: objects of class led or led subclass
            %
            % DESCRIPTION:
            % This function will convert the xy colorcoordinate into rgb
            % values, for any bit scale you want.
            
            % check if bit value is valid
            if (mod(bit,2) == 1)
                error('bit has to be n*2 !');
            else
                % get x,y,z Values
                x = obj.xyCoords(1,1);
                y = obj.xyCoords(1,2);
                z = 1 - x - y;
                % get transformation Matrix
                m = [ 0.41847, -0.15866, -0.082835;
                    -0.091169, 0.25243, 0.015708;
                    0.00092090, -0.0025498, 0.17860];
                % calculate rgb values
                rgb =  m * [x; y; z];
                % ste negative values to zero
                rgb( rgb < 0 ) = 0;
                % normalize Values
                rgb = rgb / max( rgb );
                % get rgb bit values, based on the assigned bit value
                rgb = rgb * 2^bit;
                % round up the stuff
                rgb = floor( rgb );
            end
        end
    end
end