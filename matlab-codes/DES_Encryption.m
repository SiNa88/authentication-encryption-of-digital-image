function CipherText=DES_Encryption(P,RoundKey)
% Converting P to 64-bit Binary
P_binry=reshape(reshape(dec2bin(reshape( reshape(P,2,4)',1,8),8),8,8)',1,64);   

% InitialPermutation & FinalPermutation is for
% Optimization & symmetry of the network
% By changing the places of 64 bits
P_IP=InitialPermutation_DES(P_binry);
L=P_IP(1:32);% Left part of the PlainText after Permutaion
R=P_IP(33:64);% Right part of the PlainText after Permutaion
for i=1:16  % Run the encryption rounds
    T=num2str(mod(L+F(R,RoundKey(i,:)),2)); % R(n) <=L(n-1) + f(R(n-1),K(n))
    k=1;
    for j=1:size(T,2)
        if T(1,j)~=' '
            T1(1,k)=T(1,j);
            k=k+1;
        end
    end
    Mi=[R,L];   % Swap the parts
    L=Mi(1:32); %  L(n) <= R(n-1)
    R=T1;
end
M=[R,L];	% Swap and concatenate the two sides into R16L16
CipherText_bin=FinalPermutation_DES(M);% Final Permutaion
CipherText=reshape(bin2dec(reshape(CipherText_bin,8,8)'),4,2)'; %#Converting 64-bit binary to 2*4 Matrix