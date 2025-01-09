function result = softplus(x)
    % This function takes a input fixed point i_data_a calculate
    % softplus(x) using piecewise linear, both number are in (6.10)

    if(x >= 2)
        result = fi(        x, 1, 16, 10, 'RoundingMethod', 'Nearest');
    elseif(x >= 0)
        result = fi((2*x+2)/3, 1, 16, 10, 'RoundingMethod', 'Nearest');
    elseif(x >= -1)    
        result = fi(  (x+2)/3, 1, 16, 10, 'RoundingMethod', 'Nearest');
    elseif(x >= -2)  
        result = fi((2*x+5)/9, 1, 16, 10, 'RoundingMethod', 'Nearest');
    elseif(x >= -3)  
        result = fi(  (x+3)/9, 1, 16, 10, 'RoundingMethod', 'Nearest');
    else 
        result = fi(        0, 1, 16, 10, 'RoundingMethod', 'Nearest');
    end

end