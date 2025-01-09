function fix_point = string_to_fixpoint(binary_string, bit_length, fraction_length)
    % This function takes a binary string and convert it into
    % (bit_length-fraction_length. fraction_length)fixed point signed number
    %
    % Ex: string_to_fixpoint('1000000000000000', 16, 10), it returns 100000.0000000000
    if strlength(binary_string) ~= bit_length
        error('Error message: Unmatch bit length');
    end

    decimal_value = bin2dec(binary_string);  % Convert binary to decimal

    % Handle signed interpretation (manual two's complement conversion)
    if binary_string(1) == '1'  % Check if the number is negative in two's complement
        decimal_value = decimal_value - 2^bit_length;  % Adjust to interpret as signed
    end

    fix_point = fi(decimal_value/(2^fraction_length), 1, bit_length, fraction_length, 'RoundingMethod', 'Nearest');

end
