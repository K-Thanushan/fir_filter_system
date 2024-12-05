function fixed_point_value = float_to_fixed(float_num, WL, FL)
    % FLOAT_TO_FIXED Converts a floating-point number to fixed-point representation
    % without using the fi command.
    %
    % Inputs:
    %   float_num - The floating-point number to be converted.
    %   WL - The total word length in bits.
    %   FL - The fractional length in bits.
    %
    % Output:
    %   fixed_point_value - The fixed-point representation as an integer.

    %Scaling Factor
    S = 2^FL;

    %fixed point conversion
    fixed_point_value = round(float_num*S);

    %Handle overflow
    max_val = 2^(WL-1) - 1;
    min_val = -2^(WL-1);

    if fixed_point_value > max_val
        fixed_point_value = max_val;
    elseif fixed_point_value < min_val
        fixed_point_value = min_val;
    end
end