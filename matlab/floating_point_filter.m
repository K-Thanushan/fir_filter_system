function yout = floating_point_filter(coefficients, input)
    yout = zeros(size(input));
    for n = 1:length(input)
        for k = 1:min(n, length(coefficients))
            yout(n) = yout(n) + input(n-k+1)*coefficients(k); 
        end
    end
end