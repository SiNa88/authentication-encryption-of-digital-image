function State_out=Inv_Mix_Columns(State)

Mix_inv_hex={'0E' '0B' '0D' '09';
             '09' '0E' '0B' '0D';
             '0D' '09' '0E' '0B';
             '0B' '0D' '09' '0E'};
Mix_inv=hex2dec(Mix_inv_hex);
Mix_inv=reshape(Mix_inv,4,4);

% % 
% % State1=hex2dec(State);
% % State=reshape(State1,4,4);


State_out(1:4,1:4)=0;
% In GF(2^8) {Galios field} instead of Multiplying---> Modular Multiplication and instead of Add----> XOR

% multiplication of a value by x (i.e., by {02}) can be implemented as a
% 1-bit left shift followed by a conditional bitwise XOR with (0001 1011) 
% if the leftmost bit of the original value (prior to the shift) is 1

% multiplication of a value by x^3+x^2+x (i.e., by {0E} = ({08} xor {04} xor {02}) ) can be implemented just as a conditional 
% bitwise XOR then like above a 1-bit left shift followed by a conditional bitwise XOR 

 for i=1:4
     for j=1:4
         for k=1:4
            Mixed_State=State(k,j); % Copy the cell of state to a local variable
            if Mix_inv(i,k) == 14
                % 14dec = 1110
                for h=1:3
                    Mixed_State2=Mixed_State;
                    Mixed_State=bitshift(Mixed_State,1,8);  % Shift one bit to Left all the 8 bit of Cell
                    if  bitget(uint8(Mixed_State2),8)== 1
                        Mixed_State=bitxor(Mixed_State,uint8(hex2dec('1b')));
                    end
                    State_out(i,j)=bitxor(uint8(State_out(i,j)),uint8(Mixed_State));
                end
            elseif  Mix_inv(i,k) == 13
                % 13dec = 1101
                State_out(i,j)=bitxor(uint8(State_out(i,j)),uint8(Mixed_State));
                M2=bitshift(Mixed_State,1,8);  % Shift one bit to Left all the 8 bit of Cell
                if  bitget(uint8(Mixed_State),8)== 1
                    M2=bitxor(M2,uint8(hex2dec('1b')));
                end
                %Mixed_State=M2;
                for h=1:2
                    Mixed_State=bitshift(M2,1,8);  % Shift one bit to Left all the 8 bit of Cell
                    if  bitget(uint8(M2),8)== 1
                        Mixed_State=bitxor(Mixed_State,uint8(hex2dec('1b')));
                    end
                    State_out(i,j)=bitxor(uint8(State_out(i,j)),uint8(Mixed_State));
                    M2=Mixed_State;
                end
            elseif  Mix_inv(i,k) == 11
                % 11dec = 1011
                State_out(i,j)=bitxor(uint8(State_out(i,j)),uint8(Mixed_State));
                Mixed_State=bitshift(Mixed_State,1,8);  % Shift one bit to Left all the 8 bit of Cell
                if  bitget(uint8(State(k,j)),8)== 1
                    Mixed_State=bitxor(Mixed_State,uint8(hex2dec('1b')));
                end
                State_out(i,j)=bitxor(uint8(State_out(i,j)),uint8(Mixed_State));
                M1=Mixed_State;
                M2=bitshift(M1,1,8);  % Shift one bit to Left all the 8 bit of Cell
                if  bitget(uint8(M1),8)== 1
                    M2=bitxor(M2,uint8(hex2dec('1b')));
                end
                Mixed_State=M2;
                Mixed_State=bitshift(Mixed_State,1,8);  % Shift one bit to Left all the 8 bit of Cell
                if  bitget(uint8(M2),8)== 1
                    Mixed_State=bitxor(Mixed_State,uint8(hex2dec('1b')));
                end
                State_out(i,j)=bitxor(uint8(State_out(i,j)),uint8(Mixed_State));
            elseif  Mix_inv(i,k) == 9
                State_out(i,j)=bitxor(uint8(State_out(i,j)),uint8(Mixed_State));
                M1=Mixed_State;
                for h=1:2
                    M2=bitshift(M1,1,8);  % Shift one bit to Left all the 8 bit of Cell
                    if  bitget(uint8(M1),8)== 1
                        M2=bitxor(M2,uint8(hex2dec('1b')));
                    end
                    M1=M2;
                end
                Mixed_State=M2;
                Mixed_State=bitshift(Mixed_State,1,8);  % Shift one bit to Left all the 8 bit of Cell
                if  bitget(uint8(M2),8)== 1
                    Mixed_State=bitxor(Mixed_State,uint8(hex2dec('1b')));
                end
                State_out(i,j)=bitxor(uint8(State_out(i,j)),uint8(Mixed_State));
            end
         end
     end
 end