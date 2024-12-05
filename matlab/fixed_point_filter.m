function yout = fixed_point_filter(coefficients, input, scalingfactor)
    min_val = -32768;
    max_val = 32767;
    yout = zeros(size(input));
    for n = 1:length(input)
        for k = 1:min(n, length(coefficients))
            mul_out = input(n-k+1)*coefficients(k);
            yout(n) = yout(n) + mul_out; 
        end
    end
    yout = yout / scalingfactor;
    yout = min(max(yout, min_val), max_val);
end