function CipherText=AES_Encryption(PlainText,RoundKey,S_Box)

%Copy PlainText Into The State Variable
State=PlainText;

%First XOR with The State Variable
State=Xor_Roundkey_inTo_State(State,RoundKey,0);
for r=1:10
    %Substitute each Byte with the Substitution Table
    for j=1:4
        State(j,:)=Sub_Word(State(j,:),S_Box);
    end
    %Rotating the Rows according to thier row numbers
    State=Rotate_Rows(State);
    % Mix the Cells (((the most important part of the Algorithm)))
    if r<10
        State=Mix_Columns(State);
    end
    %Xor the State Variable with the round key
    State=Xor_Roundkey_inTo_State(State,RoundKey,r);
end

% CipherText is Produced  :)
CipherText=State;