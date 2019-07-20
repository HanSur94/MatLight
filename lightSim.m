classdef lightSim 
    % simulation properties
    properties
        % starting wavelenght in [nm]
        minWave
        % ending wavelnght in [nm]
        maxWave
        % simulation steps
        steps
        % maximum luminous efficacy photopic
        KmPhot = 683.002;
        % maximum luminous efficacy scotopic
        KmScot = 1699;
    end
    
    properties (Dependent)
        % V-lambda curve photopic
        VPhot
        % V-lambda curve scotopic
        VScot
    end
    
    methods
        function vPhot = get.VPhot(obj)
          [ ~, vPhot ] = gauss_distribution2( 1 , 555 , 80 , obj.minWave , obj.maxWave, obj.steps );
        end
        function vScot = get.VScot(obj)
          [ ~, vScot ] = gauss_distribution2( 1 , 507 , 80 ,  obj.minWave , obj.maxWave, obj.steps );
        end
    end
    
    methods (Static)
        % simulation constructor
        function obj = lightSim(minWave, maxWave, steps)
            obj.minWave = minWave;
            obj.maxWave = maxWave;
            obj.steps = steps;
        end
    end
end