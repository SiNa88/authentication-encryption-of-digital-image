function S_out=Doubl2(S)
% % % If S[1] == 0 then double(S) == (S[2..128] || 0);
% % % else double(S) == (S[2..128] || 0) xor (zeros(120) || 10000111)

if S(1,1) == 0 
    S_binry=reshape(reshape(dec2bin(reshape( reshape(S,2,4)',1,8),8),8,8)',1,64);
    S_binry2(1:63)=S_binry(2:64);
    S_binry2(64)=0;
    S_out=reshape(bin2dec(reshape(S_binry2,8,8)'),2,4)';
else
    zrs=zeros(2,4);
    zrs(2,4)=bin2dec('10000111');   %(10000111)=135 denotes the 128-bit string that encodes that decimal value
    S_binry=reshape(reshape(dec2bin(reshape( reshape(S,2,4)',1,8),8),8,8)',1,64);
    S_binry2(1:63)=S_binry(2:64);
    S_binry2(64)=0;
    S2=reshape(bin2dec(reshape(S_binry2,8,8)'),4,2)';
    S_out=bitxor(S2,zrs);
end