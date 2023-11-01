function S_out=Doubl(S)
% % % If S[1] == 0 then double(S) == (S[2..128] || 0);
% % % else double(S) == (S[2..128] || 0) xor (zeros(120) || 10000111)

if S(1,1) == 0 
    S_binry=reshape(reshape(dec2bin(reshape( reshape(S,4,4)',1,16),8),16,8)',1,128);
    S_binry2(1:127)=S_binry(2:128);
    S_binry2(128)=0;
    S_out=reshape(bin2dec(reshape(S_binry2,8,16)'),4,4)';
else
    zrs=zeros(4,4);
    zrs(4,4)=bin2dec('10000111');   %(10000111)=135 denotes the 128-bit string that encodes that decimal value
    S_binry=reshape(reshape(dec2bin(reshape( reshape(S,4,4)',1,16),8),16,8)',1,128);
    S_binry2(1:127)=S_binry(2:128);
    S_binry2(128)=0;
    S2=reshape(bin2dec(reshape(S_binry2,8,16)'),4,4)';
    S_out=bitxor(S2,zrs);
end