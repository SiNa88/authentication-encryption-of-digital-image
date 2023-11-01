function DeCipher_Text=Serpent_Decryption(CipherText,RoundKey,Inv_S_Box)
%   Converting 4*4 decimal CipherText to a 128-bit Binary number
CipherText_binry=reshape(reshape(dec2bin(reshape( reshape(CipherText,4,4)', 1, 16) ,8) ,16,8)',1,128);

%   Executing InitialPermutation to deactivate FinalPermutation 
%   operarion at the end of Encryption Algorithm
E=reshape(bin2dec(reshape(InitialPermutation(CipherText_binry),8,16)'),4,4)';
CipherInvLinTrans=bitxor(E,RoundKey{33});
vector(1:32)=4;

for r=32:-1:1
    % Breaking the data into 32 piece of 4-bit Blocks
    CipherText_Block = mat2cell(reshape(reshape(dec2bin(reshape(reshape(CipherInvLinTrans,4,4)',1,16),8),16,8)',1,128),1,vector);
    
    if r < 8 
        K=r;
        A = Inv_S_Box(K,:);   % Choosing one of the eight Inv_S_Boxes
    else
        K = mod(r,8);
        A = Inv_S_Box(K+1,:);   % Choosing one of the eight Inv_S_Boxes
    end
    
    for j = 1 : 32
        Y=A(bin2dec(CipherText_Block{j})+1);    % Substituting values of Desired Inv_S_BOX for every 4-bit cell
        CipherText_Cell{j}=dec2bin(Y,4);    %   converting to binary & saving it in a cell
    end
    Cipher_Mat=reshape(bin2dec(reshape(cell2mat(CipherText_Cell),8,16)'),4,4)'; % Converting 4-bit cells to 4*4 decimal Matrix
    CipherText_AfterXor = bitxor(Cipher_Mat,RoundKey{r});   %   XORing this round data with Current RoundKey
    CipherText_AfterXor_Binry=reshape(reshape(dec2bin(reshape( reshape(CipherText_AfterXor,4,4)', 1, 16) ,8) ,16,8)' ,1,128);
    if  r == 1  %   The last round(descending) doesn't execute the InverseLinearTransformation
        break;
    else
        %   Execute the InverseLinearTransformation
        CipherInvLinTrans = reshape(bin2dec(reshape(InvLinearTransformation(CipherText_AfterXor_Binry),8,16)'),4,4)';
        %   The Output OF the Function should be converted 
        %   to 4*4 decimal matrix
    end
end
%   Returning changes in InitialPermutation function to their primary place By FinalPermutation function
P_Decrypted=FinalPermutation(CipherText_AfterXor_Binry);
DeCipher_Text=reshape(bin2dec(reshape(P_Decrypted,8,16)'),4,4)';  % Converting to 4*4 decomal Matrix