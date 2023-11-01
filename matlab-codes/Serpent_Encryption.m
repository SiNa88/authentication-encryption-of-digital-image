function CipherText=Serpent_Encryption(P,RoundKey,S_Box)
%   32-round substitution permutation network (SPN)

% Converting P to 128-bit Binary
P_binry=reshape(reshape(dec2bin(reshape( reshape(P,4,4)',1,16),8),16,8)',1,128);   

% InitialPermutation & FinalPermutation is for
% Optimization & symmetry of the network
% By changing the places of 128 bits
P_IP=InitialPermutation(P_binry);

% Reshaping to 4*4 decimal matrix
PLinTrans=reshape(bin2dec(reshape(P_IP,8,16)'),4,4)';
vector(1:32)=4;

for r=1:1:32
    P_AfterXor = bitxor(PLinTrans,RoundKey{r}); %   XORing data with Current RoundKey
    % Reshaping  4*4 decimal matrix to 128 bit binary one
    P_AfterXor_Binry=reshape(reshape(dec2bin(reshape( reshape(P_AfterXor,4,4)', 1, 16) ,8) ,16,8)' ,1,128);
    P_Block = mat2cell(P_AfterXor_Binry,1,vector);  % Breaking into thirty-two 4-bit Blocks
    if r < 8
        K=r;
        A = S_Box(K,:);   % Choosing one of the 8 S_Boxes
    else
        K = mod(r,8);
        A = S_Box(K+1,:);   % Choosing one of the 8 S_Boxes
    end
    
    for j=1:32
        Y=A(bin2dec(P_Block{j})+1); % Substituting values of Desired S_BOX for every 4 bits
        P_Cell{j}=dec2bin(Y,4);
    end
    P_Mat=cell2mat(P_Cell);  % Convert the contents which is extracted from S_BOX into a single matrix
    if  r == 32 %   The last round doesn't execute the LinearTransformation
        break;
    else
        %   Every 31 round executes the LinearTransformation Function
        PLinTrans = reshape(bin2dec(reshape(LinearTransformation(P_Mat),8,16)'),4,4)';
        %   The Output OF the Function should be converted 
        %   to 4*4 decimal matrix
    end
end
P_AfterXor=bitxor(reshape(bin2dec(reshape(P_Mat,8,16)'),4,4)',RoundKey{33});

% Every changing in InitialPermutation has to return 
% To its primary place By FinalPermutation function
P_Decrypted=FinalPermutation(reshape(reshape(dec2bin(reshape( reshape(P_AfterXor,4,4)', 1, 16) ,8) ,16,8)' ,1,128));
CipherText=reshape(bin2dec(reshape(P_Decrypted,8,16)'),4,4)';  % Converting to 4*4 Matrix