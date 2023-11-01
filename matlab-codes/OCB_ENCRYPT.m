function    [Img_Encrypted CipherText_Red CipherText_Green CipherText_Blue N]=OCB_ENCRYPT(key,Im,A)
% %     Input:
% %      key, string of KEYLEN bits                    // Key
% %      N, string of fewer than 128 bits              // Nonce
% %      A, string of any length                       // Associated data
% %      P, string of any length                       // Plaintext
% %    Output:
% %      C, string of length bitlen(P) + TAGLEN bits   // Ciphertext
tStart = tic; 
disp('Which BlockCipher Algorithm do u want? AES/Serpent');
reply = input(' if AES press A else press S? A/S  [A]: ', 's');
if isempty(reply)
    reply='A';
end

% % %   The Block Cipher Algorithm is selected
% % %   Create the S-box and the inverse S-box & 
% % %   the expanded key (schedule)
if reply == 'A' || reply == 'a'
    [S_Box   Inv_S_Box   RoundKey]=AES_Initializing(key);
    fun1=@AES_Encryption;
elseif reply == 'S' || reply == 's'
    [S_Box  Inv_S_Box    RoundKey]=Serpent_Initializing(key);
    fun1=@Serpent_Encryption;
else
    [S_Box   Inv_S_Box   RoundKey]=AES_Initializing(key);
    fun1=@AES_Encryption;
end
%     n = 255;
%     IV(1:3,1:4)= floor(n.*rand(3,4));
    IV(1:3,1:4)=[198    24   146   209;
    99    33    15     3;
    61   240    59    10];
    SizeOfOriginalPic1=size(Im);
    IV(1,1)=SizeOfOriginalPic1(1,1);
    IV(1,2)=SizeOfOriginalPic1(1,2);
    N=double(IV);
    %
    % Nonce-dependent and per-encryption variables
    %
    Top(1,1:4)= [0 0 0 1];
    Top(2:4,1:4) =N;
    Noc=dec2bin(Top(4,4),8);
    bottom = bin2dec(Noc(3:8));    % A 6-bit value Between 0~63
    Top(4,4)=double(bin2dec(strcat(Noc(1:2),'000000'))); % an 8-bit value
    Ktop = fun1( Top ,RoundKey,S_Box);  % Encrypting 
    Ktop_bin=reshape(reshape(dec2bin(reshape( reshape(Ktop,4,4)', 1, 16) ,8) ,16,8)' ,1,128);% Converting Ktop to 128-bit Binary
    %  Stretch = Ktop || (Ktop?(Ktop<<8)): this is what is done in 4 below lines
    %  Shifting every cell of the 4*4 matrix to left
    %  0 is inserted into the last cell
    Ktop_Shifted=ShiftLeft(Ktop,0);
    Stretch = Ktop_bin;
    Stretch2=bitxor(Ktop(1:2,1:4) , Ktop_Shifted(1:2,1:4));    % 256-bit String
    Stretch(129:192)=reshape(reshape(dec2bin(reshape( reshape(Stretch2,2,4)', 1, 8) ,8) ,8,8)' ,1,64);
    
    % First Offset
    Offset = reshape(bin2dec(reshape(Stretch(1+bottom:128+bottom),8,16)'),4,4)';  % The first 128 bits of Stretch << Bottom{1,1}
    Offset_Copy=Offset;
    L0=Doubl(fun1(zeros(4,4),RoundKey,S_Box));
    L{1,1}=Doubl(L0);
    warning off;
%   Gray Or RGB
if isrgb(Im)
        %  Extract the individual red, green, and blue color channels.
        redChannel = Im(:, :, 1);
        greenChannel = Im(:, :, 2);
        blueChannel = Im(:, :, 3);
        
        %%%%%%%%%%%%%%%%%%%  Red   %%%%%%%%%%%%%%%%%%
        %   If Row & Column is not to 4 it should be resized
        IRed=resize(redChannel);
        SizeOfOriginalPic2=size(IRed);
        IRed=double(IRed);    %   The Image should be converted to double
        Rows=SizeOfOriginalPic2(1,1);    Rows=Rows/4;   Vector1(1:Rows)=4;
        Cols=SizeOfOriginalPic2(1,2);    Cols=Cols/4;   Vector2(1:Cols)=4;
        
        Cell_Red=mat2cell(IRed,Vector1,Vector2);   %   Red Image is broke to 4*4 Cells
        Checksum_Red = zeros(4,4);
        for i=1:Rows
            for j=1:Cols
                if j~=1 % i~=1///i==1
                    L{i,j}=Doubl(L{i,j-1});
                elseif i~=1 && j==1
                    L{i,j}=Doubl(L{i-1,Cols});
                end
            end
        end
        %
        % Process blocks
        %
        for  i=1:Rows
             for j=1:Cols
                 if j~=1 % i~=1///i==1
                     Offset = bitxor(Offset , L{ntz(i)+1,ntz(j)+1});
                     Checksum_Red = bitxor(Checksum_Red, Cell_Red{i,j});    %XORing the checkSum By a block of red Image
                 elseif i~=1 && j==1
                     Offset   = bitxor(Offset , L{ntz(i)+1,ntz(j)+1});
                     Checksum_Red = bitxor(Checksum_Red, Cell_Red{i,j});
                 end
                C_Red{i,j} = double(bitxor( Offset , fun1( bitxor( Cell_Red{i,j} ,Offset), RoundKey,S_Box ) ));
             end
        end
        % Tag Of Red Image is Computed from the Image
        Tag_Red = double(bitxor(fun1( bitxor(bitxor(Checksum_Red , Offset) , L0), RoundKey,S_Box) , Hash(double(A),key,reply)));
     
        Img_Encrypted_Red=cell2mat(C_Red);
        %   Computing the NPCR
        disp('The NPCR between the Original Red Image & Encrypted Image :');    adad=NPCR(redChannel,Img_Encrypted_Red);disp(adad);
        %   Computing the UACI
        disp('The UACI between the Original Red Image & Encrypted Image :');    adad=UACI(redChannel,Img_Encrypted_Red);disp(adad);
        %   Computing the PSNR
        p = psnr(redChannel,Img_Encrypted_Red);  disp('The PSNR between the Original Red Image & Encrypted Image :');disp(p);
        %   Computing the Correlation Coefficient
        Img_Encrypted2=double(Img_Encrypted_Red);
        Im2=double(redChannel);
        disp('The Correlation Coefficient of the Original Red Image:');   
        x = Im2(:,1:end-1);  %# All rows and columns 1 through end-1
        y = Im2(:,2:end);    %# All rows and columns 2 through end
        h_xy_Im_Red = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy_Im_Red(1,2));
    
        disp('The Correlation Coefficient Of Encrypted Red Image :');   
        x = Img_Encrypted2(:,1:end-1);  %# All rows and columns 1 through end-1
        y = Img_Encrypted2(:,2:end);    %# All rows and columns 2 through end
        h_xy_Red = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy_Red(1,2));
        %
        % Assemble ciphertext
        %
        CipherText_Red=C_Red;
        Cipher_Size=size(CipherText_Red);
        CipherText_Red{Cipher_Size(1,1)+1,Cipher_Size(1,2)} =Tag_Red;   % Tag Of Red Image is added to CipherText
        name = getenv('COMPUTERNAME');
        CipherText_Red{Cipher_Size(1,1),Cipher_Size(1,2)+1} =name;
        clk=fix(clock);
        clk_str=strcat(int2str(clk(1,4)),': ',int2str(clk(1,5)),'min, ',int2str(clk(1,6)),'sec');
        CipherText_Red{Cipher_Size(1,1)+1,Cipher_Size(1,2)+1} =clk_str;
        
        %%%%%%%%%%%%%%%%%%%%%%%  Green   %%%%%%%%%%%%%%%%%%%%%%
        IGreen=resize(greenChannel);
        IGreen=double(IGreen);    %   The Image should be converted to double
        Cell_Green=mat2cell(IGreen,Vector1,Vector2);   %   Green Image is breaked to 4*4 Cells
        Checksum_Green = zeros(4,4);
        Offset = Offset_Copy;
        %
        % Process blocks
        %
        for  i=1:Rows
             for j=1:Cols
                 if j~=1 % i~=1///i==1
                     Offset = bitxor(Offset , L{ntz(i)+1,ntz(j)+1});
                     Checksum_Green = bitxor(Checksum_Green, Cell_Green{i,j});  %XORing the checkSum By a block of green Image
                elseif i~=1 && j==1
                     Offset   = bitxor(Offset , L{ntz(i)+1,ntz(j)+1});
                     Checksum_Green = bitxor(Checksum_Green, Cell_Green{i,j});
                 end
                C_Green{i,j} = double(bitxor( Offset , fun1( bitxor( Cell_Green{i,j} ,Offset), RoundKey,S_Box ) ));
             end
        end
        % Computing the Tag
        Tag_Green = double(bitxor(fun1( bitxor(bitxor(Checksum_Green , Offset) , L0), RoundKey,S_Box) , Hash(double(A),key,reply)));
     
        Img_Encrypted_Green=cell2mat(C_Green);
        %   Computing the NPCR
        disp('The NPCR between the Original Green Image & Encrypted Image :');    adad=NPCR(greenChannel,Img_Encrypted_Green);disp(adad);
        %   Computing the UACI
        disp('The UACI between the Original Green Image & Encrypted Image :');    adad=UACI(greenChannel,Img_Encrypted_Green);disp(adad);
        %   Computing the PSNR
        p = psnr(greenChannel,Img_Encrypted_Green);  disp('The PSNR between the Original Green Image & Encrypted Image :');disp(p);
        %   Computing the Correlation Coefficient
        Img_Encrypted2=double(Img_Encrypted_Green);
        Im2=double(greenChannel);
        disp('The Correlation Coefficient of the Original Green Image:');   
        x = Im2(:,1:end-1);  %# All rows and columns 1 through end-1
        y = Im2(:,2:end);    %# All rows and columns 2 through end
        h_xy_Im_Green = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy_Im_Green(1,2));
% %     
% %         x = Img_Encrypted2(1:end-1,:);  %#  1 through end-1 rows and All columns 
% %         y = Img_Encrypted2(2:end,:);    %# 2 through end rows and All columns 
% %         v_xy_Im_Green = corrcoef(x(:),y(:));     fprintf('Vertical is: %f\n',v_xy_Im_Green(1,2));
    
        disp('The Correlation Coefficient Of Encrypted Green Image :');   
        x = Img_Encrypted2(:,1:end-1);  %# All rows and columns 1 through end-1
        y = Img_Encrypted2(:,2:end);    %# All rows and columns 2 through end
        h_xy_Green = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy_Green(1,2));
    
% %         x = Img_Encrypted2(1:end-1,:);  %#  1 through end-1 rows and All columns 
% %         y = Img_Encrypted2(2:end,:);    %# 2 through end rows and All columns 
% %         v_xy_Green = corrcoef(x(:),y(:));     fprintf('Vertical is: %f\n',v_xy_Green(1,2));
        
        %
        % Assemble ciphertext
        %
        CipherText_Green=C_Green;
        Cipher_Size2=size(CipherText_Green);
        CipherText_Green{Cipher_Size2(1,1)+1,Cipher_Size2(1,2)} =Tag_Green; % Tag Of Green Image is added to CipherText
        name = getenv('COMPUTERNAME');
        CipherText_Green{Cipher_Size(1,1),Cipher_Size(1,2)+1} =name;
        clk=fix(clock);
        clk_str=strcat(int2str(clk(1,4)),': ',int2str(clk(1,5)),'min, ',int2str(clk(1,6)),'sec');
        CipherText_Green{Cipher_Size(1,1)+1,Cipher_Size(1,2)+1} =clk_str;
        
        %%%%%%%%%%%%%%%%%%%%%%%%  Blue   %%%%%%%%%%%%%%%%%%%%%%%%%
        IBlue=resize(blueChannel);
        IBlue=double(IBlue);    %   The Image should be converted to double
        Cell_Blue=mat2cell(IBlue,Vector1,Vector2);   %   Blue Image is broke to 4*4 Cells
        Checksum_Blue = zeros(4,4);
        Offset = Offset_Copy;
        %
        % Process blocks
        %
        for  i=1:Rows
             for j=1:Cols
                 if j~=1 % i~=1///i==1
                     Offset = bitxor(Offset , L{ntz(i)+1,ntz(j)+1});
                     Checksum_Blue = bitxor(Checksum_Blue, Cell_Blue{i,j}); %XORing the checkSum By a block of blue Image
                elseif i~=1 && j==1
                     Offset   = bitxor(Offset , L{ntz(i)+1,ntz(j)+1});
                     Checksum_Blue = bitxor(Checksum_Blue, Cell_Blue{i,j});
                 end
                C_Blue{i,j} = double(bitxor( Offset , fun1( bitxor( Cell_Blue{i,j} ,Offset), RoundKey,S_Box ) ));
             end
        end
        Tag_Blue = double(bitxor(fun1( bitxor(bitxor(Checksum_Blue , Offset) , L0), RoundKey,S_Box) , Hash(double(A),key,reply)));
     
        Img_Encrypted_Blue=cell2mat(C_Blue);
        %   Computing the NPCR
        disp('The NPCR between the Original blue Image & Encrypted Image :');    adad=NPCR(blueChannel,Img_Encrypted_Blue);disp(adad);
        %   Computing the UACI
        disp('The UACI between the Original blue Image & Encrypted Image :');    adad=UACI(blueChannel,Img_Encrypted_Blue);disp(adad);
        %   Computing the PSNR
        p = psnr(blueChannel,Img_Encrypted_Blue);  disp('The PSNR between the Original Blue Image & Encrypted Image :');disp(p);
        %   Computing the Correlation Coefficient
        Img_Encrypted2=double(Img_Encrypted_Blue);
        Im2=double(blueChannel);
        disp('The Correlation Coefficient of the Original Blue Image:');   
        x = Im2(:,1:end-1);  %# All rows and columns 1 through end-1
        y = Im2(:,2:end);    %# All rows and columns 2 through end
        h_xy_Im_Blue = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy_Im_Blue(1,2));
% %     
% %         x = Im2(1:end-1,:);  %#  1 through end-1 rows and All columns 
% %         y = Im2(2:end,:);    %# 2 through end rows and All columns 
% %         v_xy_Im_Blue = corrcoef(x(:),y(:));     fprintf('Vertical is: %f\n',v_xy_Im_Blue(1,2));
    
        disp('The Correlation Coefficient Of Encrypted Blue Image :');   
        x = Img_Encrypted2(:,1:end-1);  %# All rows and columns 1 through end-1
        y = Img_Encrypted2(:,2:end);    %# All rows and columns 2 through end
        h_xy_Blue = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy_Blue(1,2));
% %     
% %         x = Img_Encrypted2(1:end-1,:);  %#  1 through end-1 rows and All columns 
% %         y = Img_Encrypted2(2:end,:);    %# 2 through end rows and All columns 
% %         v_xy_Blue = corrcoef(x(:),y(:));     fprintf('Vertical is: %f\n',v_xy_Blue(1,2));
        
        %
        % Assemble ciphertext
        %
        CipherText_Blue=C_Blue;
        Cipher_Size=size(CipherText_Blue);
        CipherText_Blue{Cipher_Size(1,1)+1,Cipher_Size(1,2)} =Tag_Blue;     % Tag Of Blue Image is added to CipherText
        name = getenv('COMPUTERNAME');
        CipherText_Blue{Cipher_Size(1,1),Cipher_Size(1,2)+1} =name;
        clk=fix(clock);
        clk_str=strcat(int2str(clk(1,4)),': ',int2str(clk(1,5)),'min, ',int2str(clk(1,6)),'sec');
        CipherText_Blue{Cipher_Size(1,1)+1,Cipher_Size(1,2)+1} =clk_str;
        
        Img_Encrypted_Red=uint8(Img_Encrypted_Red);
        Img_Encrypted_Green=uint8(Img_Encrypted_Green);
        Img_Encrypted_Blue=uint8(Img_Encrypted_Blue);
        Img_Encrypted=0;
        figure , subplot(1,5,1), imshow(Im),title('Orginal Image'),...
            subplot(1,5,2), imshow(Img_Encrypted_Red),title('Encryp RedComponent') ,...
            subplot(1,5,3), imshow(Img_Encrypted_Green),title('Encryp GreenComponent'),...
            subplot(1,5,4), imshow(Img_Encrypted_Blue),title('Encryp BlueComponent') ,...
            subplot(1,5,5), imshow(Im),title('Decryp Img ') ;
else
%         I=resize(Im);
        SizeOfOriginalPic2=size(Im);
        
        I= double(Im);    %   The Image should be converted to double
%         [Row1 Col1]=size(Im);
%         modCol=0;
%         modRow=0;
%         if mod( Row1 , 4) ~= 0
%             if mod( Col1 , 4) ~= 0
%                 modRow=mod( Row1 , 4);
%                 modCol=mod( Col1 , 4);
%             else
%                 modRow=mod( Row1 , 4);
%             end
%         elseif mod( Col1 , 4) ~= 0
%             modCol=mod( Col1 , 4);
%         end
        Rows=SizeOfOriginalPic2(1,1);    Rows=Rows/4;        Vector1(1:Rows)=4;
        Cols=SizeOfOriginalPic2(1,2);    Cols=Cols/4;        Vector2(1:Cols)=4;
        Cell=mat2cell(I,Vector1,Vector2);   %   Image is breaked to 4*4 Cells
        Checksum = zeros(4,4);
        %%%% keySetup %%%%
        for i=1:Rows
            for j=1:Cols
                if j~=1 % i~=1///i==1
                    L{i,j}=Doubl(L{i,j-1});
                elseif i~=1 && j==1
                    L{i,j}=Doubl(L{i-1,Cols});
                end
            end
        end
        %
        % Process blocks
        %
        for  i=1:Rows
             for j=1:Cols
                 if j~=1 % i~=1///i==1
                     Offset = bitxor(Offset , L{ntz(i)+1,ntz(j)+1});
                     Checksum = bitxor(Checksum, Cell{i,j});
                elseif i~=1 && j==1
                     Offset   = bitxor(Offset , L{ntz(i)+1,ntz(j)+1});
                    Checksum = bitxor(Checksum, Cell{i,j});
                 end
                C{i,j} = double(bitxor( Offset , fun1( bitxor( Cell{i,j} ,Offset), RoundKey,S_Box ) ));
             end
        end
        Tag = double(bitxor(fun1( bitxor(bitxor(Checksum , Offset) , L0), RoundKey,S_Box) , Hash(double(A),key,reply)));
     
        Img_Encrypted=cell2mat(C);
%         %   Computing the NPCR
%         disp('The NPCR between the Original Image & Encrypted Image :');    adad=NPCR(Im,Img_Encrypted);disp(adad);
%         %   Computing the UACI
%         disp('The UACI between the Original Image & Encrypted Image :');    adad=UACI(Im,Img_Encrypted);disp(adad);
%         %   Computing the PSNR
%         p = psnr(Im,Img_Encrypted);  disp('The PSNR between the Original Image & Encrypted Image :');disp(p);
%         %   Computing the Correlation Coefficient
%         Img_Encrypted2=double(Img_Encrypted);
%         Im2=double(Im);
%         disp('The Correlation Coefficient of the Original Image:');   
%         x = Im2(:,1:end-1);  %# All rows and columns 1 through end-1
%         y = Im2(:,2:end);    %# All rows and columns 2 through end
%         h_xy_Im = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy_Im(1,2));
%         figure,plot(x(:),y(:)), title('Orginal Image')
%        
%         x = Im2(1:end-1,:);  %#  1 through end-1 rows and All columns 
%         y = Im2(2:end,:);    %# 2 through end rows and All columns 
%         v_xy_Im = corrcoef(x(:),y(:));     fprintf('Vertical is: %f\n',v_xy_Im(1,2));
%     
%         disp('The Correlation Coefficient Of Encrypted Image :');   
%         x = Img_Encrypted2(:,1:end-1);  %# All rows and columns 1 through end-1
%         y = Img_Encrypted2(:,2:end);    %# All rows and columns 2 through end
%         h_xy = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy(1,2));        
%         figure,plot(x(:),y(:)), title('Encrypted Image')
%        
%         x = Img_Encrypted2(1:end-1,:);  %#  1 through end-1 rows and All columns 
%         y = Img_Encrypted2(2:end,:);    %# 2 through end rows and All columns 
%         v_xy = corrcoef(x(:),y(:));     fprintf('Vertical is: %f\n',v_xy(1,2));
        Img_Encrypted=uint8(Img_Encrypted);
        figure,subplot(131),imhist(Im),title('Orginal Image'),...
            subplot(132),imhist(Img_Encrypted),title('Encryp Img');
            subplot(133),imhist(Im),title('Decryp Img');
%         figure , subplot(1,3,1), imshow(Im),title('Orginal Image'),...
%             subplot(1,3,2), imshow(Img_Encrypted),title('Encryp Img'),...
%             subplot(1,3,3), imshow(Im),title('Decryp Img');
        CipherText=C;
        Cipher_Size=size(CipherText);
        CipherText{Cipher_Size(1,1)+1,Cipher_Size(1,2)} =Tag;
% %         name = getenv('COMPUTERNAME');
% %         CipherText{Cipher_Size(1,1),Cipher_Size(1,2)+1} =name;
% %         clk=fix(clock);
% %         clk_str=strcat(int2str(clk(1,4)),': ',int2str(clk(1,5)),'min, ',int2str(clk(1,6)),'sec');
% %         CipherText{Cipher_Size(1,1)+1,Cipher_Size(1,2)+1} =clk_str;
        CipherText_Red=CipherText;  CipherText_Green=CipherText;  CipherText_Blue=CipherText;
end
tEnd = toc(tStart);
fprintf('%d minutes and %f seconds\n',floor(tEnd/60),rem(tEnd,60)); %to show the RunTime of algorithm