function [Img_Encrypted_red Img_Encrypted_green Img_Encrypted_blue Img_Decrypted]=OFB(Im,key)
tStart = tic;

disp('Which BlockCipher Algorithm do u want? AES/Serpent');
reply = input(' if AES press A else press S? A/S [A]: ', 's');
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
    [S_Box  Inv_S_Box  RoundKey]=Serpent_Initializing(key);
    fun1=@Serpent_Encryption;
elseif reply == 'D' || reply == 'd'
    RoundKey=KeyExpansion_DES(key(1:2,:));
    fun1=@DES_Encryption;
elseif reply == '3'
    RoundKey1=KeyExpansion_DES(key(1:2,:));
    RoundKey2=KeyExpansion_DES(key(3:4,:));
    fun1=@TripleDES;
else
    [S_Box   Inv_S_Box   RoundKey]=AES_Initializing(key);
    fun1=@AES_Encryption;
end
% n = 255;
% IV(1:4,1:4)= floor(n.*rand(4,4));
IV=[198    24   146   209;
    99    33    15     3;
    61   240    59    10;
   102   243    90    42];
IV=double(IV);
if(isrgb(Im))
    redChannel = Im(:, :, 1);
    greenChannel = Im(:, :, 2);
    blueChannel = Im(:, :, 3);
    SizeOfOriginalPic=size(Im(:,:,1));
    counter=3;
    while counter ~= 0
        if counter == 3
            I=resize(redChannel);
        elseif counter ==2
            I=resize(greenChannel);
        elseif counter ==1
            I=resize(blueChannel);
        end
        SizeOfNonOriginalPic=size(I);
        I=double(I);    %    The Image should be converted to double
    if reply == 'D' || reply == 'd' || reply == '3'
        num=2;
    else
        num=4;
    end
    Rows=SizeOfNonOriginalPic(1,1);    Rows=Rows/num;     Vector1(1:Rows)=num;
    Cols=SizeOfNonOriginalPic(1,2);    Cols=Cols/4;     Vector2(1:Cols)=4;
    Cell=mat2cell(I,Vector1,Vector2);% Vector1=Vector2=4
    IV2=IV(1:num,:);
    for i=1:Rows
        for j=1:Cols
            for k=1:num
                for s=1:4
                    if reply=='D' || reply=='d'        
                        IV_Encrypt=fun1(IV2,RoundKey);
                        IV2=ShiftLeft2(IV2,IV_Encrypt(1,1)); % Shift IV to left
                        Cell_Encryption{i,j}(k,s)=bitxor(IV_Encrypt(1,1),Cell{i,j}(k,s));
                    elseif reply=='3'
                        IV_Encrypt=fun1(IV2,RoundKey1,RoundKey2);
                        IV2=ShiftLeft2(IV2,IV_Encrypt(1,1)); % Shift IV to left
                        Cell_Encryption{i,j}(k,s)=bitxor(IV_Encrypt(1,1),Cell{i,j}(k,s));
                    else
                        IV_Encrypt=fun1(IV2,RoundKey,S_Box);
                        IV2=ShiftLeft(IV2,IV_Encrypt(1,1)); % Shift IV to left
                        Cell_Encryption{i,j}(k,s)=bitxor(IV_Encrypt(1,1),Cell{i,j}(k,s));
                    end    
                end
            end
        end
    end
    Img_Encrypted=cell2mat(Cell_Encryption);
    Cell_Encryption=mat2cell(Img_Encrypted,Vector1,Vector2);
    IV2=IV(1:num,:);
    for i=1:Rows
        for j=1:Cols
            for k=1:num
                for s=1:4
                    if reply=='D' || reply=='d'        
                        IV_Encrypt=fun1(IV2,RoundKey);
                        IV2=ShiftLeft2(IV2,IV_Encrypt(1,1)); % Shift IV to left
                        CellDecryptedPlain{i,j}(k,s)=bitxor(IV_Encrypt(1,1),Cell_Encryption{i,j}(k,s));
                    elseif reply=='3'
                        IV_Encrypt=fun1(IV2,RoundKey1,RoundKey2);
                        IV2=ShiftLeft2(IV2,IV_Encrypt(1,1)); % Shift IV to left
                        CellDecryptedPlain{i,j}(k,s)=bitxor(IV_Encrypt(1,1),Cell_Encryption{i,j}(k,s));
                    else
                        IV_Encrypt=fun1(IV2,RoundKey,S_Box);
                        IV2=ShiftLeft(IV2,IV_Encrypt(1,1)); % Shift IV to left
                        CellDecryptedPlain{i,j}(k,s)=bitxor(IV_Encrypt(1,1),Cell_Encryption{i,j}(k,s));
                    end
                end
            end
        end
    end
    Img_Decrypted=cell2mat(CellDecryptedPlain);
    Img_Decrypted=imcrop(Img_Decrypted,[0 0  SizeOfOriginalPic(1,2) SizeOfOriginalPic(1,1)]);
    I=uint8(I); 
    %   Computing the NPCR
    disp('The NPCR between the Original Image & Encrypted Image :');    adad=NPCR(I,Img_Encrypted);disp(adad);
    %   Computing the UACI
    disp('The UACI between the Original Image & Encrypted Image :');    adad=UACI(I,Img_Encrypted);disp(adad);
    %   Computing the PSNR
    p = psnr(I,Img_Encrypted);  disp('The PSNR between the Original Image & Encrypted Image :');disp(p);
    %   Computing the Correlation Coefficient
    Img_Encrypted2=double(Img_Encrypted);
    Im2=double(I);
    disp('The Correlation Coefficient of the Original Image:');   
    x = Im2(:,1:end-1);  %# All rows and columns 1 through end-1
    y = Im2(:,2:end);    %# All rows and columns 2 through end
    h_xy_Im = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy_Im(1,2));
    figure,plot(x(:),y(:)),title('Orginal Image')
    x = Im2(1:end-1,:);  %#  1 through end-1 rows and All columns 
    y = Im2(2:end,:);    %# 2 through end rows and All columns 
    v_xy_Im = corrcoef(x(:),y(:));     fprintf('Vertical is: %f\n',v_xy_Im(1,2));
    
    disp('The Correlation Coefficient Of Encrypted Image :');   
    x = Img_Encrypted2(:,1:end-1);  %# All rows and columns 1 through end-1
    y = Img_Encrypted2(:,2:end);    %# All rows and columns 2 through end
    h_xy = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy(1,2));
    figure,plot(x(:),y(:)), title('Encrypted Image')
    x = Img_Encrypted2(1:end-1,:);  %#  1 through end-1 rows and All columns 
    y = Img_Encrypted2(2:end,:);    %# 2 through end rows and All columns 
    v_xy = corrcoef(x(:),y(:));     fprintf('Vertical is: %f\n',v_xy(1,2));
    
    Img_Encrypted=uint8(Img_Encrypted);
        if counter == 3
            Img_Encrypted_red=Img_Encrypted;
            Img_Decrypted_red=Img_Decrypted;
        elseif counter ==2
            Img_Encrypted_green=Img_Encrypted;
            Img_Decrypted_green=Img_Decrypted;
        elseif counter ==1
            Img_Encrypted_blue=Img_Encrypted;
            Img_Decrypted_blue=Img_Decrypted;
        end
        counter=counter-1;
    end
        Img_Decrypted = cat(3,Img_Decrypted_red,Img_Decrypted_green,Img_Decrypted_blue);
        figure , subplot(1,5,1), imshow(Im),title('Orginal Image'),...
        subplot(1,5,2), imshow(Img_Encrypted_red),title('Encryp RedComponent') ,...
        subplot(1,5,3), imshow(Img_Encrypted_green),title('Encryp GreenComponent'),...
        subplot(1,5,4), imshow(Img_Encrypted_blue),title('Encryp BlueComponent') ,...
        subplot(1,5,5), imshow(uint8(Img_Decrypted)),title('Decryp Image');
else
    SizeOfOriginalPic1=size(Im);
    I=resize(Im);
    SizeOfNonOriginalPic=size(I);
	I=double(I);    %    The Image should be converted to double
    if reply == 'D' || reply == 'd' || reply == '3'
        num=2;
    else
        num=4;
    end
    Rows=SizeOfNonOriginalPic(1,1);    Rows=Rows/num;     Vector1(1:Rows)=num;
    Cols=SizeOfNonOriginalPic(1,2);    Cols=Cols/4;     Vector2(1:Cols)=4;
    Cell=mat2cell(I,Vector1,Vector2);% Vector1=Vector2=4
    IV2=IV(1:num,:);
    for i=1:Rows
        for j=1:Cols
            for k=1:num
                for s=1:4
                    IV2=double(IV2);
                    if reply=='D' || reply=='d'        
                        IV_Encrypt=fun1(IV2,RoundKey);
                        IV2=ShiftLeft2(IV2,IV_Encrypt(1,1)); % Shift IV to left
                        Cell_Encryption{i,j}(k,s)=bitxor(IV_Encrypt(1,1),Cell{i,j}(k,s));
                    elseif reply=='3'
                        IV_Encrypt=fun1(IV2,RoundKey1,RoundKey2);
                        IV2=ShiftLeft2(IV2,IV_Encrypt(1,1)); % Shift IV to left
                        Cell_Encryption{i,j}(k,s)=bitxor(IV_Encrypt(1,1),Cell{i,j}(k,s));
                    else
                        IV_Encrypt=fun1(IV2,RoundKey,S_Box);
                        IV2=ShiftLeft(IV2,IV_Encrypt(1,1)); % Shift IV to left
                        Cell_Encryption{i,j}(k,s)=bitxor(IV_Encrypt(1,1),Cell{i,j}(k,s));
                    end    
                end
            end
        end
    end
    Img_Encrypted=cell2mat(Cell_Encryption);
    Cell_Encryption=mat2cell(Img_Encrypted,Vector1,Vector2);
    IV2=IV(1:num,:);
    for i=1:Rows
        for j=1:Cols
            for k=1:num
                for s=1:4
                    IV2=double(IV2);
                    if reply=='D' || reply=='d'        
                        IV_Encrypt=fun1(IV2,RoundKey);
                        IV2=ShiftLeft2(IV2,IV_Encrypt(1,1)); % Shift IV to left
                        CellDecryptedPlain{i,j}(k,s)=bitxor(IV_Encrypt(1,1),Cell_Encryption{i,j}(k,s));
                    elseif reply=='3'
                        IV_Encrypt=fun1(IV2,RoundKey1,RoundKey2);
                        IV2=ShiftLeft2(IV2,IV_Encrypt(1,1)); % Shift IV to left
                        CellDecryptedPlain{i,j}(k,s)=bitxor(IV_Encrypt(1,1),Cell_Encryption{i,j}(k,s));
                    else
                        IV_Encrypt=fun1(IV2,RoundKey,S_Box);
                        IV2=ShiftLeft(IV2,IV_Encrypt(1,1)); % Shift IV to left
                        CellDecryptedPlain{i,j}(k,s)=bitxor(IV_Encrypt(1,1),Cell_Encryption{i,j}(k,s));
                    end
                end
            end
        end
    end
    Img_Decrypted=cell2mat(CellDecryptedPlain);
    Img_Decrypted=imcrop(Img_Decrypted,[0 0  SizeOfOriginalPic1(1,2) SizeOfOriginalPic1(1,1)]);
%     %   Computing the NPCR
%     disp('The NPCR between the Original Image & Encrypted Image :');    adad=NPCR(Im,Img_Encrypted);disp(adad);
%     %   Computing the UACI
%     disp('The UACI between the Original Image & Encrypted Image :');    adad=UACI(Im,Img_Encrypted);disp(adad);
%     %   Computing the PSNR
%     p = psnr(Im,Img_Encrypted);  disp('The PSNR between the Original Image & Encrypted Image :');disp(p);
%     %   Computing the Correlation Coefficient
%     Img_Encrypted2=double(Img_Encrypted);
%     Im2=double(Im);
%     disp('The Correlation Coefficient of the Original Image:');   
%     x = Im2(:,1:end-1);  %# All rows and columns 1 through end-1
%     y = Im2(:,2:end);    %# All rows and columns 2 through end
%     h_xy_Im = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy_Im(1,2));
%     figure,plot(x(:),y(:)),title('Orginal Image')
%     x = Im2(1:end-1,:);  %#  1 through end-1 rows and All columns 
%     y = Im2(2:end,:);    %# 2 through end rows and All columns 
%     v_xy_Im = corrcoef(x(:),y(:));     fprintf('Vertical is: %f\n',v_xy_Im(1,2));
%     
%     disp('The Correlation Coefficient Of Encrypted Image :');   
%     x = Img_Encrypted2(:,1:end-1);  %# All rows and columns 1 through end-1
%     y = Img_Encrypted2(:,2:end);    %# All rows and columns 2 through end
%     h_xy = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy(1,2));
%     figure,plot(x(:),y(:)), title('Encrypted Image')
%     x = Img_Encrypted2(1:end-1,:);  %#  1 through end-1 rows and All columns 
%     y = Img_Encrypted2(2:end,:);    %# 2 through end rows and All columns 
%     v_xy = corrcoef(x(:),y(:));     fprintf('Vertical is: %f\n',v_xy(1,2));
%     
    Img_Encrypted=uint8(Img_Encrypted);
    
%     figure,subplot(131),imhist(Im),title('Orginal Image'),...
%         subplot(132),imhist(Img_Encrypted),title('Encrypted Image');
%         subplot(133), imhist(uint8(Img_Decrypted)),title('Decrypted Image');
Img_Encrypted_red=Img_Encrypted;
Img_Encrypted_green=Img_Encrypted;
Img_Encrypted_blue=Img_Encrypted;
% figure,subplot(131),imshow(Im),title('Orginal Image'),...
%     subplot(132),imshow(Img_Encrypted),title('Encrypted Image');
%     subplot(133), imshow(uint8(Img_Decrypted)),title('Decrypted Image');    
end
tEnd = toc(tStart);
fprintf('%d minutes and %f seconds\n',floor(tEnd/60),rem(tEnd,60));