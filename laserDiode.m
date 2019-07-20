classdef laserDiode < led
    %% normal properties
    properties
        resonatorLenght
        refractiveIndex
        gain
        m
    end
    %% dependent properties
    properties (Dependent)
        modePeaks
        modeDist
    end
    %% for dependent props
    methods
        % peak wavelenghts for each modes
        function mPeaks = get.modePeaks( obj )
            mPeaks = 2 * obj.resonatorLenght * obj.refractiveIndex ./ obj.m * 1000;
        end
        % distance between modes
        function mDist = get.modeDist ( obj )
            mDist = obj.peak^2 / ( 2 * obj.resonatorLenght * obj.refractiveIndex );
        end
    end
    %% functions
    methods (Static)
        % constructor
        function obj = laserDiode(lightSim, name, mode,...
                peakGain, fwhmGain, ampGain,...
                resonatorLenght, refractiveIndex)
            
            obj = obj@led(lightSim ,name, mode,peakGain, fwhmGain, ampGain);
            obj.resonatorLenght = resonatorLenght;
            obj.refractiveIndex = refractiveIndex;
            obj.gain = obj.int;
            obj.int = 0;

             % create different modes
            for i = 1:1:size(obj.modePeaks,2)
                [~ , b] = gauss_distribution2(1, obj.modePeaks(1,i), 0.5, obj.minWave, obj.maxWave, obj.steps);
                b = b .* obj.gain;
                obj.int = obj.int + b;
            end
        end
        % create default laserdiode

    end
end