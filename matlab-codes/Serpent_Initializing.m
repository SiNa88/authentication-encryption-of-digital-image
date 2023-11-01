function [S_Box Inv_S_Box RoundKey]=Serpent_Initializing(key)
%Key is 128-Bit

[S_Box Inv_S_Box]=S_Box_gen_Serpent;    %    8 s-boxes with dimension 1*16 for eachOne

%Producing the Round Keys From The Master Key
RoundKey=KeyExpansion_Serpent(key,S_Box);