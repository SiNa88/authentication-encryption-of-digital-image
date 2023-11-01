function State_out=Mix_Columns(State)
% Each Column of the State Matrix is Mutlipying in a Constant Matrix in
% Galios Field GF(2^8)

% The Constant Matrix which its Cells are produced according To the
% Polynomial a(x)={03}x^3 + {01}x^2 + {01}x + {02}
Mix_hex={'02' '03' '01' '01';
         '01' '02' '03' '01';
         '01' '01' '02' '03';
         '03' '01' '01' '02'};
Mix=hex2dec(Mix_hex);
Mix=reshape(Mix,4,4);

State_out(1:4,1:4)=0;
% In GF(2^8) {Galios field} instead of Multiplying---> Modular Multiplication and instead of Add----> XOR

% multiplication of a value by x (i.e., by {02}) can be implemented as a
% 1-bit left shift followed by a conditional bitwise XOR with (0001 1011) 
% if the leftmost bit of the original value (prior to the shift) is 1

% multiplication of a value by x+1 (i.e., by {03} = ({01} xor {02}) ) can be implemented just as a conditional 
% bitwise XOR then like above a 1-bit left shift followed by a conditional bitwise XOR 
 for i=1:4
     for j=1:4
         for k=1:4
            Mixed_State=State(k,j); % Copy the cell of state to a local variable
            if Mix(i,k) == 3
                State_out(i,j)=bitxor(uint8(State_out(i,j)),uint8(Mixed_State));
                Mixed_State=bitshift(Mixed_State,1,8);  % Shift one bit to Left all the 8 bit of Cell
                if  bitget(uint8(State(k,j)),8)== 1
                    Mixed_State=bitxor(Mixed_State,uint8(hex2dec('1b')));
                end
            elseif  Mix(i,k) == 2
                Mixed_State=bitshift(Mixed_State,1,8);  % Shift one bit to Left all the 8 bit of Cell
                if  bitget(uint8(State(k,j)),8)== 1
                    Mixed_State=bitxor(Mixed_State,uint8(hex2dec('1b')));
                end
            end
            State_out(i,j)=bitxor(uint8(State_out(i,j)),uint8(Mixed_State));
         end
     end
 end