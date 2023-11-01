function out=F(R,RoundKey)
%The 'f' function as used in the encryption rounds
% For each round, we want: Rn = Ln-1 + f(Rn-1,Kn)
% f(Rn-1,Kn) is to be calculated like this:
% Kn + E(Rn-1) => B1..B8
% f = P( S1(B1)..S8(B8) )

[S1 S2 S3 S4 S5 S6 S7 S8]=S_Box_DES;

%   Expansion = 6*8 =48
Expansion=[32, 1, 2, 3, 4, 5,...    
           4, 5, 6, 7, 8, 9,...
           8, 9,10,11,12,13,...
           12,13,14,15,16,17,...
           16,17,18,19,20,21,...
           20,21,22,23,24,25,...
           24,25,26,27,28,29,...
           28,29,30,31,32,1]; 
Exp_R=R(Expansion);     %   Expand 32-bit string to 48-bit
R_Ki=num2str(mod(Exp_R+RoundKey,2));    % XOR RoundKey with Expanded 48-bit string
val1=S1(bin2dec([R_Ki(1) ,R_Ki(6) ])+1,bin2dec(R_Ki(2:5))  +1);
val2=S2(bin2dec([R_Ki(7) ,R_Ki(12)])+1,bin2dec(R_Ki(8:11)) +1);
val3=S3(bin2dec([R_Ki(13),R_Ki(18)])+1,bin2dec(R_Ki(14:17))+1);
val4=S4(bin2dec([R_Ki(19),R_Ki(24)])+1,bin2dec(R_Ki(20:23))+1);
val5=S5(bin2dec([R_Ki(25),R_Ki(30)])+1,bin2dec(R_Ki(26:29))+1);
val6=S6(bin2dec([R_Ki(31),R_Ki(36)])+1,bin2dec(R_Ki(32:35))+1);
val7=S7(bin2dec([R_Ki(37),R_Ki(42)])+1,bin2dec(R_Ki(38:41))+1);
val8=S8(bin2dec([R_Ki(43),R_Ki(48)])+1,bin2dec(R_Ki(44:47))+1);

R_Subs=[dec2bin(val1,4),dec2bin(val2,4),dec2bin(val3,4),dec2bin(val4,4),dec2bin(val5,4),dec2bin(val6,4),dec2bin(val7,4),dec2bin(val8,4)];

% FinalPermut = 1*32 permutation of bits in f function
FinalPermut=[16,7,20,21,29,12,28,17,...
             1,15,23,26,5,18,31,10,...
             2,8,24,14,32,27,3,9,...
             19,13,30,6,22,11,4,25];
out     =    R_Subs(FinalPermut);%  decreasing 48-bit string to 32-bit one