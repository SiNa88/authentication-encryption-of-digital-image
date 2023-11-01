function DeCipher_Text=AES_Decryption(CipherText,RoundKey,Inv_S_Box)
% decryption round has the structure InvShiftRows, InvSubBytes,
% AddRoundKey, InvMixColumns.
Cipher_State=CipherText;

%First XOR with The State Variable
Cipher_State=Xor_Roundkey_inTo_State(Cipher_State,RoundKey,10);
for r=9:-1:0
    %Inv_Rotating the Rows according to thier row numbers
    Cipher_State=Inv_Rotate_Rows(Cipher_State);
    %Inv_Substitute each Byte with the Substitution Table
    for j=1:4
        Cipher_State(j,:)=Inv_Sub_Word(Cipher_State(j,:),Inv_S_Box);
    end
    %Xor the State Variable with the round key
    Cipher_State=Xor_Roundkey_inTo_State(Cipher_State,RoundKey,r);
    % Inv_Mix the Cells (((the most important part of the Algorithm)))
    if r > 0
        Cipher_State=Inv_Mix_Columns(Cipher_State);
    end 
end
% DeCipherText is Produced  :)
DeCipher_Text=Cipher_State;