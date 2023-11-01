function K=KeyExpansion_DES(key)
%   producing 48-bit roundkeys from the 56-bit master key
%   permutation choise 1 = PC1 = 1*56 
key_binry=reshape(reshape(dec2bin(reshape( reshape(key,2,4)',1,8),8),8,8)',1,64);  
key_PC1=key_binry(1,[57,49,41,33,25,17,9,1,...
    58,50,42,34,26,18,10,2,...
    59,51,43,35,27,19,11,3,...
    60,52,44,36,63,55,47,39,...
    31,23,15,7,62,54,46,38,...
    30,22,14,6,61,53,45,37,...
    29,21,13,5,28,20,12,4]); 
%   permutation choise 2 = PC2 = 1*48
PC2=[14,17,11,24,1,5,3,28,...
    15,6,21,10,23,19,12,4,...
    26,8,16,7,27,20,13,2,...
    41,52,31,37,47,55,30,40,...
    51,45,33,48,44,49,39,56,...
    34,53,46,42,50,36,29,32];
L=key_PC1(1:28); 
R=key_PC1(29:56); 
% This is the schedule of shifts. 
% Each LnRn is produced by shifting the previous by 1 or 2
% The Round Number [1   2   3   4   5   6   7   8   9  10  11   12  13 14  15  16]
% Number Of shifts [1 , 1 , 2 , 2 , 2 , 2 , 2 , 2 , 1 , 2 , 2 , 2 , 2 , 2 , 2 , 1]
for i=1:16
    if i==1||1==2||i==9||i==16
        L=[L(2:28),L(1)];
        R=[R(2:28),R(1)];
    else
        L=[L(3:28),L(1:2)];
        R=[R(3:28),R(1:2)];
    end
    Ki=[L,R];
    K(i,:)=Ki(PC2);
end