classdef whiteLed < led
    %% create new subclass of led, a white led
    %% add white led properties
    properties
        peakWhite
        fwhmWhite
        ampWhite
    end
    methods (Static)
        %% white led constuctor
        function obj = whiteLed(lightSim, name, mode,...
                peakBlue, fwhmBlue, ampBlue,...
                peakWhite, fwhmWhite, ampWhite)
            
            obj = obj@led(lightSim, name, mode, peakBlue, fwhmBlue, ampBlue);
            
            if ( nargin == 9 )
                obj.peakWhite = peakWhite;
                obj.fwhmWhite = fwhmWhite;
                obj.ampWhite = ampWhite;
                [ ~ , b ]  =  gauss_distribution2( ampWhite, peakWhite, fwhmWhite, obj.minWave, obj.maxWave, obj.steps);
                obj.int = obj.int + b;            
            end
            if (nargin <9 )
                error('Not enough input arguments');
            end
            if (nargin > 9 )
                error('Too many input arguments');
            end
        end
        %% print white led data
        function printLed( varargin )
            for i = 1:1:size(varargin,2)
                led.printLed(varargin{1,i});
                fprintf( 'Peak White Wavelenght: %d nm\n FWHM White: %d nm\n Amplitude White: %d %s\n',...
                    varargin{1,i}.peakWhite, varargin{1,i}.fwhmWhite,...
                    varargin{1,i}.ampWhite, varargin{1,i}.mode);
            end
        end
    end
end