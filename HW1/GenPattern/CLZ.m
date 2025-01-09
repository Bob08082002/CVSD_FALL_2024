function result = CLZ(x)
    % This function takes a input fixed point X , calculate
    % it's leading zeros

   x_binary_str = bin(x);

   first_one_index = 17;
   for i = 1:16
        if(x_binary_str(i) == '1')
           first_one_index = i;
           break;
        end
   end

   result = first_one_index - 1;
   
end