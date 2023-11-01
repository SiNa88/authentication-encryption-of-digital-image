function pRound = LinearTransformation(P_Mat)
%  Tabdile Khatiii
%   It is a set of Rotaions & Shifts & XORs
vector2(1:4)=32;
X = mat2cell(P_Mat,1,vector2);   % Breaking the 128-Bit to 32-Bit Blocks
X{1}=bin2dec(X{1});X{2}=bin2dec(X{2});X{3}=bin2dec(X{3});X{4}=bin2dec(X{4});
X{1}=bitRotate(X{1},13); % X1 := X1 <<< 13 (Rotation) 
X{3}=bitRotate(X{3},3);  % X3 := X3 <<< 3 
X{2}=bitxor(bitxor(X{2},X{1}),X{3});                 % X2 xor X1 xor X3
X{4}=bitxor(bitxor(X{4},X{3}),bitshift( X{1},3,32)); % X4 xor X3 xor (X1<<3)
X{2}=bitRotate(X{2},1);  % X2 := X2 <<< 1 
X{4}=bitRotate(X{4},7);  % X4 := X4 <<< 7 
X{1}=bitxor(bitxor(X{1},X{2}),X{4});
X{3}=bitxor(bitxor(X{3},X{4}),bitshift( X{2},7,32));
X{1}=bitRotate(X{1},5);  % X1 := X1 <<< 5 
X{3}=bitRotate(X{3},22); % X3 := X3 <<< 22 
X{1}=dec2bin(X{1},32);X{2}=dec2bin(X{2},32);X{3}=dec2bin(X{3},32);X{4}=dec2bin(X{4},32);
pRound=cell2mat(X);      %Combining the 32-Bit Blocks into a 128-Bit Block