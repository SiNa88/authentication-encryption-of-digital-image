function    P=OCB_DECRYPT2(key,N,A,C1,C2,C3)
% %     Input:
% %      key, string of KEYLEN bits                    // Key
% %      N, string of fewer than 128 bits              // Nonce
% %      A, string of any length                       // Associated data
% %      C, string of at least TAGLEN bits             // Ciphertext
% %    Output:
% %      P, string of length bitlen(C) - TAGLEN bits,  // Plaintext
% %           or INVALID indicating authentication failure
tStart = tic; 
disp('Which BlockCipher Algorithm do u want? AES/Serpent');
reply = input(' if AES press A else press S? A/S [A]: ', 's');
if isempty(reply)
    reply='A';
end


% % %   The Block Cipher Algorithm is selected
% % %   Create the S-box and the inverse S-box & 
% % %   the expanded key (schedule)
if reply == 'd' || reply == 'D'
    RoundKey=KeyExpansion_DES(key(1:2,:));
    fun1=@DES_Encryption;
    fun2=@DES_Decryption;
elseif reply == '3'
    RoundKey1=KeyExpansion_DES(key(1:2,:));
    RoundKey2=KeyExpansion_DES(key(3:4,:));
    fun1=@TripleDES;
    fun2=@Triple_Decryption;
else
    RoundKey=KeyExpansion_DES(key(1:2,:));
    fun1=@DES_Encryption;
    fun2=@DES_Decryption;
end

Top(1,1:4)= [0 0 0 1];    % First row of 4*4 Nonce matrix
Top(2,1:4) =N;  %   2,3,4 rows of 4*4 Nonce matrix
Noc=dec2bin(Top(2,4),8);
bottom = bin2dec(Noc(3:8));    % A value Between 0~63
Top(2,4)=double(bin2dec(strcat(Noc(1:2),'000000')));
if reply == 'D' || reply == 'd'
        Ktop = fun1( Top ,RoundKey);
elseif reply == '3'
        Ktop = fun1( Top ,RoundKey1,RoundKey2);
end
Ktop_bin=reshape(reshape(dec2bin(reshape( reshape(Ktop,2,4)', 1, 8) ,8) ,8,8)' ,1,64);% Converting Ktop to 128-bit Binary
    %  Stretch = Ktop || (Ktop?(Ktop<<8)): this is what is done in 4 below
    %  lines
    
    %   Shifting every cell of the 4*4 matrix to left
    %   0 is inserted into the last cell
    Ktop_Shifted=ShiftLeft2(Ktop,0);
    Stretch = Ktop_bin ;
    Stretch2=bitxor(Ktop(1:2,1:4) , Ktop_Shifted(1:2,1:4));    % 256-bit String
    Stretch(65:128)=reshape(reshape(dec2bin(reshape( reshape(Stretch2,2,4)', 1, 8) ,8) ,8,8)' ,1,64);
    % First Offset
    Offset = reshape(bin2dec(reshape(Stretch(1+bottom:64+bottom),8,8)'),4,2)';  % The first 128 bits of Stretch << Bottom{1,1}
    Offset_Copy=Offset;
    if reply == 'D' || reply == 'd'
        L0=Doubl2(fun1(zeros(2,4),RoundKey));
    elseif reply == '3'
    	L0=Doubl2(fun1(zeros(2,4),RoundKey1,RoundKey2));
    end
    L{1,1}=Doubl2(L0);
    warning off;
    
if isequal(C1,C2,C3)
    Cipher_Size=size(C1);
    Rows=Cipher_Size(1,1); 
    Cols=Cipher_Size(1,2);
    T=C1{Rows,Cols-1};    
    name=C1{Rows-1,Cols};    
    disp(name);
    TIME=C1{Rows,Cols};
    disp('The time when Gray Image was encrypted : ');
    disp(TIME);
    for i=1:Rows-1
        for j=1:Cols-1
            if j~=1 % i~=1///i==1
                L{i,j}=Doubl2(L{i,j-1});
            elseif i~=1 && j==1
                L{i,j}=Doubl2(L{i-1,Cols-1});
            end
        end
    end
    %
    % Nonce-dependent and per-encryption variables
    %
     Checksum = zeros(2,4);
     P{1,1} = double(bitxor( Offset , fun2( bitxor( C1{1,1} ,Offset), RoundKey ) ));
     %
     % Process any whole blocks
     %
     for  i=1:Rows-1
         for j=1:Cols-1
             if j~=1 % i~=1///i==1
                 Offset = bitxor(Offset , L{ntz(i)+1,ntz(j)+1});
                 P{i,j} = double(bitxor( Offset , fun2( bitxor( C1{i,j} ,Offset), RoundKey ) ));
                 Checksum = bitxor(Checksum, P{i,j});
             elseif i~=1 && j==1
                 Offset = bitxor(Offset , L{ntz(i)+1,ntz(j)+1});
                 P{i,j} = double(bitxor( Offset , fun2( bitxor( C1{i,j} ,Offset), RoundKey) ));
                 Checksum = bitxor(Checksum, P{i,j});
             end
         end
     end
     
     Tag = double(bitxor(fun1( bitxor(bitxor(Checksum , Offset) , L0), RoundKey) , Hash2(double(A),key,reply)));
     
     Im_Decrypted=cell2mat(P);  % Combining the cells in to a single Matrix to obtain the deciphered Image
     SizeOfOriginalPic1 =N(1,1);
     SizeOfOriginalPic2 =N(1,2);
     % Croping the decipherd image to its first size!
     P=imcrop(Im_Decrypted,[0 0  SizeOfOriginalPic2 SizeOfOriginalPic1]);
     
     Ciphertext=C1(1:Rows-1,1:Cols-1);
     Im_Encrypted=cell2mat(Ciphertext); % Encrypted recieved image
     
     figure, subplot(1,2,1), imshow(uint8(Im_Encrypted)),title('Encryp Img'),... 
         subplot(1,2,2),imshow(uint8(P)),title('Decryp Img');

     if T==Tag
         disp('The palin Text is Valid :)')
     else
         disp('The palin Text is not Valid!!!! :(')
     end
else
    Cipher_Size=size(C1);
    Rows=Cipher_Size(1,1); 
    Cols=Cipher_Size(1,2);   
    for i=1:Rows-1
        for j=1:Cols-1
            if j~=1 % i~=1///i==1
                L{i,j}=Doubl2(L{i,j-1});
            elseif i~=1 && j==1
                L{i,j}=Doubl2(L{i-1,Cols-1});
            end
        end
    end
     %%%%%%%%%%%%  Red   %%%%%%%%%%
     %
     % Nonce-dependent and per-encryption variables
     %
     T1=C1{Rows,Cols-1};
     name=C1{Rows-1,Cols};    
     disp(name);
     TIME=C1{Rows,Cols};
     disp('The time when Red Component was encrypted : ');
     disp(TIME);
     Checksum_Red = zeros(2,4);
     P1{1,1} = double(bitxor( Offset , fun2( bitxor( C1{1,1} ,Offset), RoundKey ) ));
     %
     % Process any whole blocks
     %
     for  i=1:Rows-1
         for j=1:Cols-1
             if j~=1 % i~=1///i==1
                 Offset = bitxor(Offset , L{ntz(i)+1,ntz(j)+1});
                 P1{i,j} = double(bitxor( Offset , fun2( bitxor( C1{i,j} ,Offset), RoundKey) ));
                 Checksum_Red = bitxor(Checksum_Red, P1{i,j});
             elseif i~=1 && j==1
                 Offset = bitxor(Offset , L{ntz(i)+1,ntz(j)+1});
                 P1{i,j} = double(bitxor( Offset , fun2( bitxor( C1{i,j} ,Offset), RoundKey) ));
                 Checksum_Red = bitxor(Checksum_Red, P1{i,j});
             end
         end
     end
     
    Tag_Red = double(bitxor(fun1( bitxor(bitxor(Checksum_Red , Offset) , L0), RoundKey) , Hash2(double(A),key,reply)));
    Im_Decrypted_Red=cell2mat(P1);% Combining the cells in to a single Matrix to obtain the deciphered Red Image
    
    %%%%%%%%%%%%  Green   %%%%%%%%%%
    %
    % Nonce-dependent and per-encryption variables
    %
    T2=C2{Rows,Cols-1};
    name=C2{Rows-1,Cols};    
    disp(name);
    TIME=C2{Rows,Cols};
    disp('The time when Green Component was encrypted : ');
    disp(TIME);
    Checksum_Green = zeros(2,4);
    Offset = Offset_Copy;
    P2{1,1} = double(bitxor( Offset , fun2( bitxor( C2{1,1} ,Offset), RoundKey) ));
    %
    % Process any whole blocks
    %
     for  i=1:Rows-1
         for j=1:Cols-1
             if j~=1 % i~=1///i==1
                 Offset = bitxor(Offset , L{ntz(i)+1,ntz(j)+1});
                 P2{i,j} = double(bitxor( Offset , fun2( bitxor( C2{i,j} ,Offset), RoundKey) ));
                 Checksum_Green = bitxor(Checksum_Green, P2{i,j});
             elseif i~=1 && j==1
                 Offset = bitxor(Offset , L{ntz(i)+1,ntz(j)+1});
                 P2{i,j} = double(bitxor( Offset , fun2( bitxor( C2{i,j} ,Offset), RoundKey) ));
                 Checksum_Green = bitxor(Checksum_Green, P2{i,j});
             end
         end
     end
     
     Tag_Green = double(bitxor(fun1( bitxor(bitxor(Checksum_Green , Offset) , L0), RoundKey) , Hash2(double(A),key,reply)));
     
     Im_Decrypted_Green=cell2mat(P2);   % Combining the cells in to a single Matrix to obtain the deciphered green Image
     
     %%%%%%%%%%%%  Blue   %%%%%%%%%%
     %
     % Nonce-dependent and per-encryption variables
     %
     T3=C3{Rows,Cols-1};
     name=C3{Rows-1,Cols};    
     disp(name);
     TIME=C3{Rows,Cols};
     disp('The time when Blue Component was encrypted : ');
     disp(TIME);
     Checksum_Blue = zeros(2,4);
     Offset = Offset_Copy;
     P3{1,1} = double(bitxor( Offset , fun2( bitxor( C3{1,1} ,Offset), RoundKey) ));
     %
     % Process any whole blocks
     %
     for  i=1:Rows-1
         for j=1:Cols-1
             if j~=1 % i~=1///i==1
                 Offset = bitxor(Offset , L{ntz(i)+1,ntz(j)+1});
                 P3{i,j} = double(bitxor( Offset , fun2( bitxor( C3{i,j} ,Offset), RoundKey) ));
                 Checksum_Blue = bitxor(Checksum_Blue, P3{i,j});
             elseif i~=1 && j==1
                 Offset = bitxor(Offset , L{ntz(i)+1,ntz(j)+1});
                 P3{i,j} = double(bitxor( Offset , fun2( bitxor( C3{i,j} ,Offset), RoundKey) ));
                 Checksum_Blue = bitxor(Checksum_Blue, P3{i,j});
             end
         end
     end
     
     Tag_Blue = double(bitxor(fun1( bitxor(bitxor(Checksum_Blue , Offset) , L0), RoundKey) , Hash2(double(A),key,reply)));
     
     Im_Decrypted_Blue=cell2mat(P3);    % Combining the cells in to a single Matrix to obtain the deciphered blue Image
     
     SizeOfOriginalPic1 =N(1,1);
     SizeOfOriginalPic2 =N(1,2);
     P_Red=imcrop(Im_Decrypted_Red,[0 0  SizeOfOriginalPic2 SizeOfOriginalPic1]);
     P_Green=imcrop(Im_Decrypted_Green,[0 0  SizeOfOriginalPic2 SizeOfOriginalPic1]);
     P_Blue=imcrop(Im_Decrypted_Blue,[0 0  SizeOfOriginalPic2 SizeOfOriginalPic1]);
     
     Img_Decrypted_red=uint8(P_Red);
     Img_Decrypted_green=uint8(P_Green);
     Img_Decrypted_blue=uint8(P_Blue);

     Img_Decrypted = cat(3,Img_Decrypted_red,Img_Decrypted_green,Img_Decrypted_blue);
     figure,imshow(uint8(Img_Decrypted)),title('Decryp Img');
     P=Img_Decrypted;
     if (T1==Tag_Red) 
         if (T2==Tag_Green) 
             if(T3==Tag_Blue)
                 disp('The plain Text is Valid :)');
             else
                 disp('3 The plain Text is not Valid!!!! :(');
             end
         else
             disp('2 The plain Text is not Valid!!!! :(');
         end
     else
         disp('1 The plain Text is not Valid!!!! :(');
     end
end
tEnd = toc(tStart);
fprintf('%d minutes and %f seconds\n',floor(tEnd/60),rem(tEnd,60));