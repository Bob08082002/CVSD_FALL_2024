function result = reverse_match4(a, b)
    % This function takes two inputs fixed point a & b , calculate
    % reverse match4
    
    result_str = '0000000000000000';
    a_bin_str = bin(a);
    b_bin_str = bin(b);

    for i = 0:12
        
        if strcmp(a_bin_str(13-i:16-i), b_bin_str(i+1:i+4))
            result_str(16 - i) = '1';
        end
    end

    result = string_to_fixpoint(result_str, 16, 10);
   
end