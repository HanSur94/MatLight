function sr = A2Sr( fullAngle )
    % sr = A2Sr(obj)
    %
    % Parameters:
    % fullAngle: double: full opening angle of an Led
    %
    % Output:
    % sr: double: steradiant of the led
    %
    % Description:
    % This function will convert the full opening angle of an led into its
    % steradiant, based on the following formula:
    %
    %      sr = 2 * pi * ( 1 - cos( fullAngle / 180 * pi / 2 )  )
    sr = 2 * pi * ( 1 - cos( fullAngle / 180 * pi / 2 )  );
end