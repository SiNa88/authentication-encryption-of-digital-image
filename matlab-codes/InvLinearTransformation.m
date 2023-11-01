function CipherRound=InvLinearTransformation(CipherText_Mat)
%  Axe Tabdile Khatiii
%Binary
vector2(1:4)=32;
X = mat2cell(CipherText_Mat,1,vector2);   % Breaking the 128-Bit to 32-Bit Blocks
X{1}=bin2dec(X{1});X{2}=bin2dec(X{2});X{3}=bin2dec(X{3});X{4}=bin2dec(X{4});
X{3}=bitRotate(X{3},10); % X3 := X3 <<< 10 
X{1}=bitRotate(X{1},27);  % X1 := X1 <<< 27 
X{3}=bitxor(bitxor(X{3},X{4}),bitshift( X{2},7,32));%%%%
X{1}=bitxor(bitxor(X{1},X{2}),X{4});
X{4}=bitRotate(X{4},25);  % X4 := X4 <<< 25 
X{2}=bitRotate(X{2},31);  % X2 := X2 <<< 31 
X{4}=bitxor(bitxor(X{4},X{3}),bitshift( X{1},3,32)); % X4 xor X3 xor (X1<<3)        %%%%%%
X{2}=bitxor(bitxor(X{2},X{1}),X{3});                 % X2 xor X1 xor X3
X{3}=bitRotate(X{3},29);  % X3 := X3 <<< 29 
X{1}=bitRotate(X{1},19); % X1 := X1 <<< 19 (Rotation) 
X{1}=dec2bin(X{1},32);X{2}=dec2bin(X{2},32);X{3}=dec2bin(X{3},32);X{4}=dec2bin(X{4},32);
CipherRound=cell2mat(X);      %Combining the 32-Bit Blocks into a 128-Bit Block