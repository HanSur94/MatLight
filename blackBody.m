classdef blackBody < led
    
    properties
       temp
    end
    
   methods (Static)
       
       function obj = blackBody(lightSim, name, mode, amp, temp)
           
           obj = obj@led(lightSim, name, mode, 0, 0, 0);
           
           obj.amp = amp;
           obj.temp = temp;
           
           [ obj.lambda, obj.int ] = bbrad(obj.temp, obj.minWave, obj.maxWave, obj.steps);

       end
      
       
   end
end