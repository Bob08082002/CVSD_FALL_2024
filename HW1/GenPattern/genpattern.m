%% start

clear
close all
clc

%Must bigger than  SPECIAL_NUM*SPECIAL_NUM + BOUND_ANS_NUM_I01 & SPECIAL_NUM*SPECIAL_NUM + BOUND_ANS_NUM_I2*2 & SPECIAL_NUM + BOUND_NUM + BOUND_IN_NUM_I4
TOTAL_PATTERN_NUM = 10000; 


Shape = zeros(TOTAL_PATTERN_NUM,10); % Pattern_number*10 array
A_fix_matrix = fi(Shape,1,16,10,'RoundingMethod','Nearest'); % convert float64 Z_doub matrix to fixed point(6.10) matrix
B_fix_matrix = fi(Shape,1,16,10,'RoundingMethod','Nearest'); %fixed point(6.10) range is [-32, 31.999]
Ans_fix_matrix = fi(Shape,1,16,10,'RoundingMethod','Nearest');


SPECIAL_NUM = 5; % total 'SPECIAL_NUM * SPECIAL_NUM' data
NEG_BOUND = string_to_fixpoint('1000000000000000', 16, 10);
POS_BOUND = string_to_fixpoint('0111111111111111', 16, 10);
ZERO = string_to_fixpoint('0000000000000000', 16, 10);
POS_SMALL = string_to_fixpoint('0000000000000001', 16, 10);
NEG_SMALL = string_to_fixpoint('1111111111111111', 16, 10);
SPECIAL_LIST = [NEG_BOUND, POS_BOUND, ZERO, POS_SMALL, NEG_SMALL];

% add, sub: corner case such that result is closed to bound(bound +- 1)
BOUND_ANS_NUM_I01 = 6000; % total 'BOUND_ANS_NUM_I01' data

% mul: corner case such that result is closed to bound (7.20). 
% prevent overflow
BOUND_ANS_NUM_I2 = 3000;  % total '2 * BOUND_ANS_NUM_I2' data

% softplus: cases which input is in range [-4,4]. piecewise nonlinearity.
BOUND_IN_NUM_I4 = 6000; % total 'BOUND_IN_NUM_I4' data 

%% For I0 I1 ADD & SUB
input_range_addsub = 34; %input range of I0(sum) and I1(sub), ex: [-34, 34]

% result is in (7.10)
POS_BOUND_plus  = fi(POS_BOUND + 1/2^10, 1,17,10,'RoundingMethod','Nearest'); 
POS_BOUND_minus = fi(POS_BOUND - 1/2^10, 1,17,10,'RoundingMethod','Nearest'); 
NEG_BOUND_plus  = fi(NEG_BOUND + 1/2^10, 1,17,10,'RoundingMethod','Nearest'); 
NEG_BOUND_minus = fi(NEG_BOUND - 1/2^10, 1,17,10,'RoundingMethod','Nearest'); 

for inst = 1:2
    index = 0;

    % use SPECIAL_NUM to gen corner case % total: SPECIAL_NUM * SPECIAL_NUM
    for i = 1:SPECIAL_NUM
        for j = 1:SPECIAL_NUM
            index = index + 1;

            A_fix_matrix(index, inst) = SPECIAL_LIST(i); 
            B_fix_matrix(index, inst) = SPECIAL_LIST(j);

            if inst == 1
                Ans_fix_matrix(index, inst) = fi(SPECIAL_LIST(i) + SPECIAL_LIST(j),1,16,10,'RoundingMethod','Nearest'); 
            elseif inst == 2
                Ans_fix_matrix(index, inst) = fi(SPECIAL_LIST(i) - SPECIAL_LIST(j),1,16,10,'RoundingMethod','Nearest'); 
            end

        end
    end

    % To gen corner case such that result in an ans which is closed to
    % bound
    for i = 1:BOUND_ANS_NUM_I01
        index = index + 1;

        if i <= BOUND_ANS_NUM_I01/4
            Final_ans = POS_BOUND_plus;
        elseif i <= BOUND_ANS_NUM_I01*2/4
            Final_ans = POS_BOUND_minus;
        elseif i <= BOUND_ANS_NUM_I01*3/4
            Final_ans = NEG_BOUND_plus;
        else
            Final_ans = NEG_BOUND_minus;
        end

        A_float = 2*input_range_addsub*rand(1)-input_range_addsub;  % generate a float64 number in range [-input_range_addsub,input_range_addsub]   
        A_fix = fi(A_float,1,16,10,'RoundingMethod','Nearest'); % convert float64 to fixed point(6.10)

        if inst == 1     
            B_fix = fi(Final_ans - A_fix ,1,16,10,'RoundingMethod','Nearest');
            Ans_fix = fi(A_fix + B_fix,1,16,10,'RoundingMethod','Nearest'); 

        elseif inst == 2
            B_fix = fi(A_fix - Final_ans ,1,16,10,'RoundingMethod','Nearest');
            Ans_fix = fi(A_fix - B_fix,1,16,10,'RoundingMethod','Nearest'); 

        end
        
        A_fix_matrix(index, inst) = A_fix; 
        B_fix_matrix(index, inst) = B_fix;
        Ans_fix_matrix(index, inst) = Ans_fix;
        
    end
    
    num_of_test_data_sofar = index;
  
    % random testing data
    for i = 1:TOTAL_PATTERN_NUM - num_of_test_data_sofar
        index = index + 1;

        A_float = 2*input_range_addsub*rand(1)-input_range_addsub;  % generate a float64 number in range [-input_range_addsub,input_range_addsub]
        B_float = 2*input_range_addsub*rand(1)-input_range_addsub;  
        
        A_fix = fi(A_float,1,16,10,'RoundingMethod','Nearest'); % convert float64 to fixed point(6.10)
        B_fix = fi(B_float,1,16,10,'RoundingMethod','Nearest');

        if inst == 1
            Ans_fix = fi(A_fix + B_fix,1,16,10,'RoundingMethod','Nearest'); 
        elseif inst == 2
            Ans_fix = fi(A_fix - B_fix,1,16,10,'RoundingMethod','Nearest'); 
        end
        
        A_fix_matrix(index, inst) = A_fix; 
        B_fix_matrix(index, inst) = B_fix;
        Ans_fix_matrix(index, inst) = Ans_fix;
    end
end

%% For I2 MULTPLICATION
inst = 3;
index = 0;

% use SPECIAL_NUM to gen corner case % total: SPECIAL_NUM * SPECIAL_NUM
for i = 1:SPECIAL_NUM
    for j = 1:SPECIAL_NUM
        index = index + 1;
        A_fix_matrix(index, inst) = SPECIAL_LIST(i); 
        B_fix_matrix(index, inst) = SPECIAL_LIST(j); 
        Ans_fix_matrix(index, inst) = fi(SPECIAL_LIST(i) * SPECIAL_LIST(j),1,16,10,'RoundingMethod','Nearest'); 
    end
end

% To gen corner case such that result in an answer which is closed to
% bound (7.20)
for i = 1:BOUND_ANS_NUM_I2

    Final_ans_float = 2*64*rand(1)-64;  % generate a float64 number in range [-64,64] (7.20)
    Final_ans  = fi(Final_ans_float, 1,27,20,'RoundingMethod','Nearest'); 

    for iter = 1:2

        index = index + 1;

        if iter == 1 % A is smaller
             A_float = 2*4*rand(1)-4;  % generate a float64 number in range [-4,4]   
             A_fix = fi(A_float,1,16,10,'RoundingMethod','Nearest'); % convert float64 to fixed point(6.10)
             if A_fix ~= 0
                B_fix = fi(Final_ans / A_fix ,1,16,10,'RoundingMethod','Nearest');
             else
                B_fix = fi((2*4*rand(1)-4) ,1,16,10,'RoundingMethod','Nearest');
             end
             Ans_fix = fi(A_fix * B_fix,1,16,10,'RoundingMethod','Nearest');
        else  % B is smaller
             B_float = 2*4*rand(1)-4;  % generate a float64 number in range [-4,4]   
             B_fix = fi(B_float,1,16,10,'RoundingMethod','Nearest'); % convert float64 to fixed point(6.10)
             if B_fix ~= 0
                A_fix = fi(Final_ans / B_fix ,1,16,10,'RoundingMethod','Nearest');
             else
                A_fix = fi((2*4*rand(1)-4) ,1,16,10,'RoundingMethod','Nearest');
             end
             Ans_fix = fi(A_fix * B_fix,1,16,10,'RoundingMethod','Nearest');
        end
        A_fix_matrix(index, inst) = A_fix; 
        B_fix_matrix(index, inst) = B_fix;
        Ans_fix_matrix(index, inst) = Ans_fix;
    end

end
    
num_of_test_data_sofar = index;

% random testing data which inputs both in range -34 ~ 34
% result overflow often
for i = 1:TOTAL_PATTERN_NUM - num_of_test_data_sofar
    index = index + 1;
    A_float = 2*input_range_addsub*rand(1)-input_range_addsub;  % generate a float64 number in range [-input_range_addsub,input_range_addsub]
    B_float = 2*input_range_addsub*rand(1)-input_range_addsub;  
    
    A_fix = fi(A_float,1,16,10,'RoundingMethod','Nearest'); % convert float64 to fixed point(6.10)
    B_fix = fi(B_float,1,16,10,'RoundingMethod','Nearest');
    Ans_fix = fi(A_fix * B_fix,1,16,10,'RoundingMethod','Nearest'); 
    
    A_fix_matrix(index, inst) = A_fix; 
    B_fix_matrix(index, inst) = B_fix;
    Ans_fix_matrix(index, inst) = Ans_fix;
end

%% For I3 ACCUMULATION
inst = 4;
index = 0;

data_acc_shape = zeros(16,1);
data_acc = fi(data_acc_shape ,1,20,10,'RoundingMethod','Nearest'); %accumulation list
data_acc_upperbound = fi((2^19-1)/2^10 ,1,20,10,'RoundingMethod','Nearest'); %upper bound of (10.10), intermediate values are guaranteed not to exceed 20 bits(10.10)
data_acc_lowerbound = fi((-2^19)/2^10 ,1,20,10,'RoundingMethod','Nearest');

% random testing data which inputs in range -34 ~ 34
for i = 1:TOTAL_PATTERN_NUM
    index = index + 1;
    random_index = randi([1, 16]); %random integer between 1 ~ 16

    while true % Run the loop until accumulation result not to exceed 20 bits(10.10)
        B_float = 2*input_range_addsub*rand(1)-input_range_addsub;  % generate a float64 number in range [-input_range_addsub,input_range_addsub]   
        B_fix = fi(B_float,1,16,10,'RoundingMethod','Nearest'); % convert float64 to fixed point(6.10)
        if (data_acc(random_index) + B_fix) <= data_acc_upperbound && (data_acc(random_index) + B_fix) >= data_acc_lowerbound
            break;  % Exit the loop when accumulation result not to exceed 20 bits(10.10)
        end
    end
    % assign new accumulation list
    data_acc(random_index) = data_acc(random_index) + B_fix; 
    Ans_fix = fi(data_acc(random_index),1,16,10,'RoundingMethod','Nearest'); 

    A_fix_matrix(index, inst) =  fi((random_index - 1)/2^10, 1, 16, 10, 'RoundingMethod','Nearest'); 
    B_fix_matrix(index, inst) = B_fix;
    Ans_fix_matrix(index, inst) = Ans_fix;
end

%% for I4 SOFTPLUS
inst = 5;
index = 0;

% result is in (6.10)
BOUND_NUM = 5;
BOUND_1 = fi( 2, 1,16,10,'RoundingMethod','Nearest'); 
BOUND_2 = fi( 0, 1,16,10,'RoundingMethod','Nearest'); 
BOUND_3 = fi(-1, 1,16,10,'RoundingMethod','Nearest'); 
BOUND_4 = fi(-2, 1,16,10,'RoundingMethod','Nearest'); 
BOUND_5 = fi(-3, 1,16,10,'RoundingMethod','Nearest'); 
BOUND = [BOUND_1, BOUND_2, BOUND_3, BOUND_4, BOUND_5];



% use SPECIAL_NUM to gen corner case % total: SPECIAL_NUM
for i = 1:SPECIAL_NUM
   index = index + 1;
   A_fix_matrix(index, inst) = SPECIAL_LIST(i); 
   Ans_fix_matrix(index, inst) = fi(softplus(SPECIAL_LIST(i)),1,16,10,'RoundingMethod','Nearest'); 
end
% use BOUND_NUM to gen cases which equals to boundary of pieces % total: BOUND_NUM
for i = 1:BOUND_NUM
   index = index + 1;
   A_fix_matrix(index, inst) = BOUND(i); 
   Ans_fix_matrix(index, inst) = fi(softplus(BOUND(i)),1,16,10,'RoundingMethod','Nearest'); 
end
% use BOUND_IN_NUM_I4 to gen cases which input is in range [-4,4]
for i = 1:BOUND_IN_NUM_I4
    index = index + 1;

    A_float = 2*4*rand(1)-4;  % generate a float64 number in range [-4,4]   
    A_fix = fi(A_float,1,16,10,'RoundingMethod','Nearest'); % convert float64 to fixed point(6.10)
    A_fix_matrix(index, inst) = A_fix; 
    Ans_fix_matrix(index, inst) = fi(softplus(A_fix),1,16,10,'RoundingMethod','Nearest'); 
end
num_of_test_data_sofar = index;
% random testing data which inputs in range -34 ~ 34
for i = 1:TOTAL_PATTERN_NUM - num_of_test_data_sofar
    index = index + 1;
    
    A_float = 2*input_range_addsub*rand(1)-input_range_addsub;  % generate a float64 number in range [-input_range_addsub,input_range_addsub]   
    A_fix = fi(A_float,1,16,10,'RoundingMethod','Nearest'); % convert float64 to fixed point(6.10)
    A_fix_matrix(index, inst) = A_fix; 
    Ans_fix_matrix(index, inst) = fi(softplus(A_fix),1,16,10,'RoundingMethod','Nearest'); 

end

%% for I5 BITWISE XOR, I6 SHIFT RIGHT, I7 LEFT ROTATE

for inst = 6:8
    index = 0;
    for i = 1:TOTAL_PATTERN_NUM
        index = index + 1;

        A_float = 2*input_range_addsub*rand(1)-input_range_addsub;  % generate a float64 number in range [-input_range_addsub,input_range_addsub]
        A_fix = fi(A_float,1,16,10,'RoundingMethod','Nearest'); % convert float64 to fixed point(6.10)

        if inst == 6 % I5 bitwise XOR
            B_float = 2*input_range_addsub*rand(1)-input_range_addsub;  
            B_fix = fi(B_float,1,16,10,'RoundingMethod','Nearest');
            Ans_fix = bitxor(A_fix, B_fix);
        elseif inst == 7 % I6 shift right,
            B_float = randi([0, 16]); %random integer between 0 ~ 16
            Ans_fix = bitsra(A_fix, B_float);
            B_fix = fi(B_float/2^10 ,1,16,10,'RoundingMethod','Nearest');
        elseif inst == 8 % I7 left rotate
            B_float = randi([0, 16]); %random integer between 0 ~ 16
            Ans_fix = bitrol(A_fix, B_float);
            B_fix = fi(B_float/2^10 ,1,16,10,'RoundingMethod','Nearest');
        end

        A_fix_matrix(index, inst) = A_fix;
        B_fix_matrix(index, inst) = B_fix;
        Ans_fix_matrix(index, inst) = Ans_fix;
    end
end
%% for I8 COUNTING LEADING ZEROS
inst = 9;
index = 0;

% use SPECIAL_NUM to gen corner case % total: SPECIAL_NUM
for i = 1:SPECIAL_NUM
   index = index + 1;
   A_fix_matrix(index, inst) = SPECIAL_LIST(i); 
   Ans_fix_matrix(index, inst) = fi(CLZ(SPECIAL_LIST(i))/2^10 ,1,16,10,'RoundingMethod','Nearest'); 
end
num_of_test_data_sofar = index;
% random testing data which inputs in range -34 ~ 34
for i = 1:TOTAL_PATTERN_NUM - num_of_test_data_sofar
    index = index + 1;
    A_float = 2*input_range_addsub*rand(1)-input_range_addsub;  % generate a float64 number in range [-input_range_addsub,input_range_addsub]   
    A_fix = fi(A_float,1,16,10,'RoundingMethod','Nearest'); % convert float64 to fixed point(6.10)
    A_fix_matrix(index, inst) = A_fix; 
    Ans_fix_matrix(index, inst) = fi(CLZ(A_fix)/2^10 ,1,16,10,'RoundingMethod','Nearest'); 
end

%% for I9 REVERSE MATCH4
inst = 10;
index = 0;

% random testing data which inputs in range -34 ~ 34
for i = 1:TOTAL_PATTERN_NUM
    index = index + 1;
    A_float = 2*input_range_addsub*rand(1)-input_range_addsub;  % generate a float64 number in range [-input_range_addsub,input_range_addsub]   
    A_fix = fi(A_float,1,16,10,'RoundingMethod','Nearest'); % convert float64 to fixed point(6.10)
    B_float = 2*input_range_addsub*rand(1)-input_range_addsub;  % generate a float64 number in range [-input_range_addsub,input_range_addsub]   
    B_fix = fi(B_float,1,16,10,'RoundingMethod','Nearest'); % convert float64 to fixed point(6.10)

    A_fix_matrix(index, inst) = A_fix; 
    B_fix_matrix(index, inst) = B_fix; 
    Ans_fix_matrix(index, inst) = fi(reverse_match4(A_fix, B_fix),1,16,10,'RoundingMethod','Nearest'); 
end

%% Write separate pattern file
for inst = 1:10
    fid = fopen(strcat('./MY_pattern/','INST', int2str(inst-1), '_I.dat'), 'wt');
    for w = 1:TOTAL_PATTERN_NUM
        inst_print = dec2bin(inst-1);
        fprintf(fid ,'%04s' ,inst_print);
        fprintf(fid ,'%s' ,bin(A_fix_matrix(w,inst)));
        fprintf(fid ,'%s' ,bin(B_fix_matrix(w,inst)));
        fprintf(fid ,'\n');
    end
    fclose(fid);
    fid = fopen(strcat('./MY_pattern/','INST', int2str(inst-1), '_O.dat'), 'wt');
    for w = 1:TOTAL_PATTERN_NUM
        fprintf(fid ,'%s' ,bin(Ans_fix_matrix(w,inst)));
        fprintf(fid ,'\n');
    end
    fclose(fid);
end


% ----- VALID.dat ------
% Define the numbers
num_ones = TOTAL_PATTERN_NUM;
total_length = round(num_ones*2);
% Create a sequence with num_ones ones and the rest zeros
sequence = [ones(1, num_ones), zeros(1, total_length - num_ones)];
% Randomize the sequence
random_sequence = sequence(randperm(total_length));
% Write the sequence to a file
fileID = fopen('./MY_pattern/VALID.dat', 'w');
for i = 1:total_length
    fprintf(fileID, '%d\n', random_sequence(i));
end
fclose(fileID);

fprintf('Seperate testing data PAT_LEN = %d\n', num_ones);
fprintf('Seperate testing data SEQ_LEN = %d\n', total_length);

%% Write MIX pattern file 
% create inst_matrix
inst_matrix = ones(TOTAL_PATTERN_NUM, 10);
for inst = 1:10
    for i = 1:TOTAL_PATTERN_NUM
        inst_matrix(i, inst) = inst - 1;
    end
end

% Reshape matrices into column vectors
A_fix_col   = A_fix_matrix(:);    % (TOTAL_PATTERN_NUM*10)x1 column vector
B_fix_col   = B_fix_matrix(:);    % (TOTAL_PATTERN_NUM*10)x1 column vector
Ans_fix_col = Ans_fix_matrix(:);  % (TOTAL_PATTERN_NUM*10)x1 column vector
inst_col    = inst_matrix(:);     % (TOTAL_PATTERN_NUM*10)x1 column vector


% Generate random permutation of indices
shuffle_idx = randperm(length(A_fix_col));  % Shuffle indices from 1 to TOTAL_PATTERN_NUM*10

% Shuffle the column vectors according to the random indices
A_fix_shuffled = A_fix_col(shuffle_idx);
B_fix_shuffled = B_fix_col(shuffle_idx);
Ans_fix_shuffled = Ans_fix_col(shuffle_idx);
inst_shuffled = inst_col(shuffle_idx);

index_I3 = 0;
fid = fopen(strcat('./MY_pattern/','INST_MIX_I.dat'), 'wt');
for w = 1:length(A_fix_col)
    inst_print = dec2bin(inst_shuffled(w));

    if(inst_shuffled(w) == 3) %I3 % Accumlation cannot be shuffled
        index_I3 = index_I3 + 1;
        fprintf(fid ,'%04s' ,inst_print);
        fprintf(fid ,'%s' ,bin(A_fix_matrix(index_I3, 4)));
        fprintf(fid ,'%s' ,bin(B_fix_matrix(index_I3, 4)));
        fprintf(fid ,'\n');
    else
        fprintf(fid ,'%04s' ,inst_print);
        fprintf(fid ,'%s' ,bin(A_fix_shuffled(w)));
        fprintf(fid ,'%s' ,bin(B_fix_shuffled(w)));
        fprintf(fid ,'\n');
    end
    
end
fclose(fid);

index_I3 = 0;
fid = fopen(strcat('./MY_pattern/','INST_MIX_O.dat'), 'wt');
for w = 1:length(A_fix_col)

    if(inst_shuffled(w) == 3) %I3 % Accumlation cannot be shuffled
        index_I3 = index_I3 + 1;
        fprintf(fid ,'%s' ,bin(Ans_fix_matrix(index_I3, 4)));
        fprintf(fid ,'\n');
    else
        fprintf(fid ,'%s' ,bin(Ans_fix_shuffled(w)));
        fprintf(fid ,'\n');
    end

end
fclose(fid);


% ------ VALID_MIX.dat ------
% Define the numbers
num_ones = length(A_fix_col);
total_length = round(num_ones*2);
% Create a sequence with num_ones ones and the rest zeros
sequence = [ones(1, num_ones), zeros(1, total_length - num_ones)];
% Randomize the sequence
random_sequence = sequence(randperm(total_length));
% Write the sequence to a file
fileID = fopen('./MY_pattern/VALID_MIX.dat', 'w');
for i = 1:total_length
    fprintf(fileID, '%d\n', random_sequence(i));
end
fclose(fileID);

fprintf('MIX testing data PAT_LEN = %d\n', num_ones);
fprintf('MIX testing data SEQ_LEN = %d\n', total_length);
