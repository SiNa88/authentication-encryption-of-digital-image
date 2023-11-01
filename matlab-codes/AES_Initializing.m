function [S_Box Inv_S_Box RoundKey]=AES_Initializing(key)
%Key is 128 Bits
[S_Box Inv_S_Box]=S_Box_gen_AES;
%Producing the Round Keys From The Master Key
RoundKey=KeyExpansion_AES(key,S_Box);