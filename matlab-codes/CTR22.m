function [Img_Encrypted_red Img_Encrypted_green Img_Encrypted_blue Img_Decrypted]=CTR22(Im,key)
% [Img_Encrypted Img_Decrypted]
tStart = tic; 
% n = 255;
% IV(1:4,1:4)= floor(n.*rand(4,4));
IV=[198    24   146   209;
    99    33    15     3;
    61   240    59    10;
   102   243    90    43];
% % %   The Block Cipher Algorithm is selected
% % fun1=@AES_Encryption;
% % 
% % %   The Block Cipher Algorithm is selected
% % fun2=@AES_Decryption;
% disp('Which BlockCipher Algorithm do u want? AES/Serpent/DES/3-DES');
% reply = input(' if AES press A else press S? A/S/D/3 [A]: ', 's');
reply='A';
% if isempty(reply)
%     reply='A';
% end


% % %   The Block Cipher Algorithm is selected
% % %   Create the S-box and the inverse S-box & 
% % %   the expanded key (schedule)
if reply == 'A' || reply == 'a'
    [S_Box   Inv_S_Box   RoundKey]=AES_Initializing(key);
    fun1=@AES_Encryption;
elseif reply == 'S' || reply == 's'
    [S_Box  Inv_S_Box    RoundKey]=Serpent_Initializing(key);
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

warning off;
%   Gray Or RGB
if isrgb(Im)
        
    %  Extract the individual red, green, and blue color channels.
    redChannel = Im(:, :, 1);
    greenChannel = Im(:, :, 2);
    blueChannel = Im(:, :, 3);
   
    %%%%%%%%%%%%  Red   %%%%%%%%%%
    SizeOfOriginalPic1=size(redChannel);
    
    %   If Row & Column is not to 4 it should be resized
    IRed=resize(redChannel);

    SizeOfOriginalPic2=size(IRed);
    if reply=='D' || reply=='d' || reply=='3'
        Rows=SizeOfOriginalPic2(1,1);    Rows=Rows/2;       Vector1(1:Rows)=2;
    else
        Rows=SizeOfOriginalPic2(1,1);    Rows=Rows/4;       Vector1(1:Rows)=4;
    end
    Cols=SizeOfOriginalPic2(1,2);    Cols=Cols/4;       Vector2(1:Cols)=4;
    
    IRed=double(IRed);    %    The Image should be converted to double
    Cell=mat2cell(IRed,Vector1,Vector2);
    IV2=IV;
    for i=1:Rows
        for j=1:Cols
            IV2=double(IV2);
            if reply=='D' || reply=='d'
                Cel2=fun1(IV2(1:2,:),RoundKey);
            elseif reply=='3'
                Cel2=fun1(IV2(1:2,:),RoundKey1,RoundKey2);
            else
                Cel2=fun1(IV2,RoundKey,S_Box);
            end
            Cell{i,j}=bitxor(Cell{i,j},Cel2);
            IV2=uint8(IV2);
            if reply=='D' || reply=='d' || reply == '3'
                IV_new=hex2dec(strcat(dec2hex(IV2(2,1),2),dec2hex(IV2(2,2),2),dec2hex(IV2(2,3),2),dec2hex(IV2(2,4),2)))+1;
                IV_new=dec2hex(IV_new,8);
                IV2(2,1)=hex2dec(strcat(IV_new(1,1),IV_new(1,2)));
                IV2(2,2)=hex2dec(strcat(IV_new(1,3),IV_new(1,4)));
                IV2(2,3)=hex2dec(strcat(IV_new(1,5),IV_new(1,6)));
                IV2(2,4)=hex2dec(strcat(IV_new(1,7),IV_new(1,8)));
            else
                IV_new=hex2dec(strcat(dec2hex(IV2(4,1),2),dec2hex(IV2(4,2),2),dec2hex(IV2(4,3),2),dec2hex(IV2(4,4),2)))+1;
                IV_new=dec2hex(IV_new,8);
                IV2(4,1)=hex2dec(strcat(IV_new(1,1),IV_new(1,2)));
                IV2(4,2)=hex2dec(strcat(IV_new(1,3),IV_new(1,4)));
                IV2(4,3)=hex2dec(strcat(IV_new(1,5),IV_new(1,6)));
                IV2(4,4)=hex2dec(strcat(IV_new(1,7),IV_new(1,8)));
            end
        end
    end
    Img_Encrypted_Red=cell2mat(Cell);
    
    %   Computing the NPCR
    disp('The NPCR between the Red Component of Original Image & Encrypted Image :');    adad=NPCR(redChannel,Img_Encrypted_Red);disp(adad);
    
    %   Computing the UACI
    disp('The UACI between the Red Component of Original Image & Encrypted Image :');    adad=UACI(redChannel,Img_Encrypted_Red);disp(adad);
    
    %   Computing the PSNR
    p = psnr(redChannel,Img_Encrypted_Red);  disp('The PSNR between the Red Component of Original Image & Encrypted Image :');disp(p);
    Img_Encrypted2=double(Img_Encrypted_Red);
    %   Computing the Correlation Coefficient
    Im2=double(redChannel);
    disp('The Correlation Coefficient of the red Component of Original Image:');   
    x = Im2(:,1:end-1);  %# All rows and columns 1 through end-1
    y = Im2(:,2:end);    %# All rows and columns 2 through end
    h_xy_Im = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy_Im(1,2));
    
    disp('The Correlation Coefficient Of Encrypted Image :');   
    x = Img_Encrypted2(:,1:end-1);  %# All rows and columns 1 through end-1
    y = Img_Encrypted2(:,2:end);    %# All rows and columns 2 through end
    h_xy = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy(1,2));
    
    Cell_Encryption_red=mat2cell(Img_Encrypted_Red,Vector1,Vector2);
    IV2=IV;
    for i=1:Rows
        for j=1:Cols
            IV2=double(IV2);
            if reply=='D' || reply=='d'
                Cel3=fun1(IV2(1:2,:),RoundKey);
            elseif reply=='3'
                Cel3=fun1(IV2(1:2,:),RoundKey1,RoundKey2);
            else
                Cel3=fun1(IV2,RoundKey,S_Box);
            end
            Cell_Encryption_red{i,j}=bitxor(Cell_Encryption_red{i,j},Cel3);
            IV2=uint8(IV2);
            if reply=='D' || reply=='d' || reply == '3'
                IV_new=hex2dec(strcat(dec2hex(IV2(2,1),2),dec2hex(IV2(2,2),2),dec2hex(IV2(2,3),2),dec2hex(IV2(2,4),2)))+1;
                IV_new=dec2hex(IV_new,8);
                IV2(2,1)=hex2dec(strcat(IV_new(1,1),IV_new(1,2)));
                IV2(2,2)=hex2dec(strcat(IV_new(1,3),IV_new(1,4)));
                IV2(2,3)=hex2dec(strcat(IV_new(1,5),IV_new(1,6)));
                IV2(2,4)=hex2dec(strcat(IV_new(1,7),IV_new(1,8)));
            else
                IV_new=hex2dec(strcat(dec2hex(IV2(4,1),2),dec2hex(IV2(4,2),2),dec2hex(IV2(4,3),2),dec2hex(IV2(4,4),2)))+1;
                IV_new=dec2hex(IV_new,8);
                IV2(4,1)=hex2dec(strcat(IV_new(1,1),IV_new(1,2)));
                IV2(4,2)=hex2dec(strcat(IV_new(1,3),IV_new(1,4)));
                IV2(4,3)=hex2dec(strcat(IV_new(1,5),IV_new(1,6)));
                IV2(4,4)=hex2dec(strcat(IV_new(1,7),IV_new(1,8)));
            end
        end
    end
    Img_Decrypted_red=cell2mat(Cell_Encryption_red);
    Img_Decrypted_red=imcrop(Img_Decrypted_red,[0 0  SizeOfOriginalPic1(1,2) SizeOfOriginalPic1(1,1)]);
    
    %%%%%%%%%%%%  Green   %%%%%%%%%%
    %   If Row & Column is not to 4 it should be resized
    IGreen=resize(greenChannel);
    
    IGreen=double(IGreen);    %    The Image should be converted to double
    Cell=mat2cell(IGreen,Vector1,Vector2);
    IV2=IV;
    for i=1:Rows
        for j=1:Cols
            if reply=='D' || reply=='d'
                Cel2=fun1(IV2(1:2,:),RoundKey);
            elseif reply=='3'
                Cel2=fun1(IV2(1:2,:),RoundKey1,RoundKey2);
            else
                Cel2=fun1(IV2,RoundKey,S_Box);
            end
            Cell{i,j}=bitxor(Cell{i,j},Cel2);
            IV2=uint8(IV2);
            if reply=='D' || reply=='d' || reply == '3'
                IV_new=hex2dec(strcat(dec2hex(IV2(2,1),2),dec2hex(IV2(2,2),2),dec2hex(IV2(2,3),2),dec2hex(IV2(2,4),2)))+1;
                IV_new=dec2hex(IV_new,8);
                IV2(2,1)=hex2dec(strcat(IV_new(1,1),IV_new(1,2)));
                IV2(2,2)=hex2dec(strcat(IV_new(1,3),IV_new(1,4)));
                IV2(2,3)=hex2dec(strcat(IV_new(1,5),IV_new(1,6)));
                IV2(2,4)=hex2dec(strcat(IV_new(1,7),IV_new(1,8)));
            else
                IV_new=hex2dec(strcat(dec2hex(IV2(4,1),2),dec2hex(IV2(4,2),2),dec2hex(IV2(4,3),2),dec2hex(IV2(4,4),2)))+1;
                IV_new=dec2hex(IV_new,8);
                IV2(4,1)=hex2dec(strcat(IV_new(1,1),IV_new(1,2)));
                IV2(4,2)=hex2dec(strcat(IV_new(1,3),IV_new(1,4)));
                IV2(4,3)=hex2dec(strcat(IV_new(1,5),IV_new(1,6)));
                IV2(4,4)=hex2dec(strcat(IV_new(1,7),IV_new(1,8)));
            end
        end
    end
    Img_Encrypted_Green=cell2mat(Cell);
    
    %   Computing the NPCR
    disp('The NPCR between the the green Component of Original Image & Encrypted Image :');    adad=NPCR(greenChannel,Img_Encrypted_Green);disp(adad);
    
    %   Computing the UACI
    disp('The UACI between the the green Component of Original Image & Encrypted Image :');    adad=UACI(greenChannel,Img_Encrypted_Green);disp(adad);
    
    %   Computing the PSNR
    p = psnr(greenChannel,Img_Encrypted_Green);  disp('The PSNR between the green compon of Original Image & Encrypted Image :');disp(p);
    Img_Encrypted2=double(Img_Encrypted_Green);
    
    %   Computing the Correlation Coefficient
    Im2=double(greenChannel);
    disp('The Correlation Coefficient of the red Component of Original Image:');   
    x = Im2(:,1:end-1);  %# All rows and columns 1 through end-1
    y = Im2(:,2:end);    %# All rows and columns 2 through end
    h_xy_Im = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy_Im(1,2));
%     
%     x = Im2(1:end-1,:);  %#  1 through end-1 rows and All columns 
%     y = Im2(2:end,:);    %# 2 through end rows and All columns 
%     v_xy_Im = corrcoef(x(:),y(:));     fprintf('Vertical is: %f\n',v_xy_Im(1,2));
    
    disp('The Correlation Coefficient Of Encrypted Image :');   
    x = Img_Encrypted2(:,1:end-1);  %# All rows and columns 1 through end-1
    y = Img_Encrypted2(:,2:end);    %# All rows and columns 2 through end
    h_xy = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy(1,2));
%     
%     x = Img_Encrypted2(1:end-1,:);  %#  1 through end-1 rows and All columns 
%     y = Img_Encrypted2(2:end,:);    %# 2 through end rows and All columns 
%     v_xy = corrcoef(x(:),y(:));     fprintf('Vertical is: %f\n',v_xy(1,2));
    Cell_Encryption_green=mat2cell(Img_Encrypted_Green,Vector1,Vector2);
    IV2=IV;
    for i=1:Rows
        for j=1:Cols
            IV2=double(IV2);
            if reply=='D' || reply=='d'
                Cel3=fun1(IV2(1:2,:),RoundKey);
            elseif reply=='3'
                Cel3=fun1(IV2(1:2,:),RoundKey1,RoundKey2);
            else
                Cel3=fun1(IV2,RoundKey,S_Box);
            end
            Cell_Encryption_green{i,j}=bitxor(Cell_Encryption_green{i,j},Cel3);
            IV2=uint8(IV2);
            if reply=='D' || reply=='d' || reply == '3'
                IV_new=hex2dec(strcat(dec2hex(IV2(2,1),2),dec2hex(IV2(2,2),2),dec2hex(IV2(2,3),2),dec2hex(IV2(2,4),2)))+1;
                IV_new=dec2hex(IV_new,8);
                IV2(2,1)=hex2dec(strcat(IV_new(1,1),IV_new(1,2)));
                IV2(2,2)=hex2dec(strcat(IV_new(1,3),IV_new(1,4)));
                IV2(2,3)=hex2dec(strcat(IV_new(1,5),IV_new(1,6)));
                IV2(2,4)=hex2dec(strcat(IV_new(1,7),IV_new(1,8)));
            else
                IV_new=hex2dec(strcat(dec2hex(IV2(4,1),2),dec2hex(IV2(4,2),2),dec2hex(IV2(4,3),2),dec2hex(IV2(4,4),2)))+1;
                IV_new=dec2hex(IV_new,8);
                IV2(4,1)=hex2dec(strcat(IV_new(1,1),IV_new(1,2)));
                IV2(4,2)=hex2dec(strcat(IV_new(1,3),IV_new(1,4)));
                IV2(4,3)=hex2dec(strcat(IV_new(1,5),IV_new(1,6)));
                IV2(4,4)=hex2dec(strcat(IV_new(1,7),IV_new(1,8)));
            end
        end
    end
    Img_Decrypted_green=cell2mat(Cell_Encryption_green);
    Img_Decrypted_green=imcrop(Img_Decrypted_green,[0 0  SizeOfOriginalPic1(1,2) SizeOfOriginalPic1(1,1)]);
    
    %%%%%%%%%%%%  Blue  %%%%%%%%%%
    %   If Row & Column is not to 4 it should be resized
    IBlue=resize(blueChannel);
    IBlue=double(IBlue);    %    The Image should be converted to double
    Cell=mat2cell(IBlue,Vector1,Vector2);
    IV2=IV;
    for i=1:Rows
        for j=1:Cols
            if reply=='D' || reply=='d'
                Cel2=fun1(IV2(1:2,:),RoundKey);
            elseif reply=='3'
                Cel2=fun1(IV2(1:2,:),RoundKey1,RoundKey2);
            else
                Cel2=fun1(IV2,RoundKey,S_Box);
            end
            Cell{i,j}=bitxor(Cell{i,j},Cel2);
            IV2=uint8(IV2);
            if reply=='D' || reply=='d' || reply == '3'
                IV_new=hex2dec(strcat(dec2hex(IV2(2,1),2),dec2hex(IV2(2,2),2),dec2hex(IV2(2,3),2),dec2hex(IV2(2,4),2)))+1;
                IV_new=dec2hex(IV_new,8);
                IV2(2,1)=hex2dec(strcat(IV_new(1,1),IV_new(1,2)));
                IV2(2,2)=hex2dec(strcat(IV_new(1,3),IV_new(1,4)));
                IV2(2,3)=hex2dec(strcat(IV_new(1,5),IV_new(1,6)));
                IV2(2,4)=hex2dec(strcat(IV_new(1,7),IV_new(1,8)));
            else
                IV_new=hex2dec(strcat(dec2hex(IV2(4,1),2),dec2hex(IV2(4,2),2),dec2hex(IV2(4,3),2),dec2hex(IV2(4,4),2)))+1;
                IV_new=dec2hex(IV_new,8);
                IV2(4,1)=hex2dec(strcat(IV_new(1,1),IV_new(1,2)));
                IV2(4,2)=hex2dec(strcat(IV_new(1,3),IV_new(1,4)));
                IV2(4,3)=hex2dec(strcat(IV_new(1,5),IV_new(1,6)));
                IV2(4,4)=hex2dec(strcat(IV_new(1,7),IV_new(1,8)));
            end
        end
    end
    Img_Encrypted_Blue=cell2mat(Cell);
    
    %   Computing the NPCR
    disp('The NPCR between the blue of Original Image & Encrypted Image :');    adad=NPCR(blueChannel,Img_Encrypted_Blue);disp(adad);
    
    %   Computing the UACI
    disp('The UACI between the blue of Original Image & Encrypted Image :');    adad=UACI(blueChannel,Img_Encrypted_Blue);disp(adad);
    
    %   Computing the PSNR
    p = psnr(blueChannel,Img_Encrypted_Blue);  disp('The PSNR between the blue of  Original Image & Encrypted Image :');disp(p);
    Img_Encrypted2=double(Img_Encrypted_Blue);
    
    %   Computing the Correlation Coefficient
    Im2=double(blueChannel);
    disp('The Correlation Coefficient of the blue of Original Image:');   
    x = Im2(:,1:end-1);  %# All rows and columns 1 through end-1
    y = Im2(:,2:end);    %# All rows and columns 2 through end
    h_xy_Im = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy_Im(1,2));
    
%     x = Img_Encrypted2(1:end-1,:);  %#  1 through end-1 rows and All columns 
%     y = Img_Encrypted2(2:end,:);    %# 2 through end rows and All columns 
%     v_xy_Im = corrcoef(x(:),y(:));     fprintf('Vertical is: %f\n',v_xy_Im(1,2));
    
    disp('The Correlation Coefficient Of Encrypted Image :');   
    x = Img_Encrypted2(:,1:end-1);  %# All rows and columns 1 through end-1
    y = Img_Encrypted2(:,2:end);    %# All rows and columns 2 through end
    h_xy = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy(1,2));
    
%     x = Img_Encrypted2(1:end-1,:);  %#  1 through end-1 rows and All columns 
%     y = Img_Encrypted2(2:end,:);    %# 2 through end rows and All columns 
%     v_xy = corrcoef(x(:),y(:));     fprintf('Vertical is: %f\n',v_xy(1,2));
    Cell_Encryption_blue=mat2cell(Img_Encrypted_Blue,Vector1,Vector2);
    IV2=IV;
    for i=1:Rows
        for j=1:Cols
            IV2=double(IV2);
            if reply=='D' || reply=='d'
                Cel3=fun1(IV2(1:2,:),RoundKey);
            elseif reply=='3'
                Cel3=fun1(IV2(1:2,:),RoundKey1,RoundKey2);
            else
                Cel3=fun1(IV2,RoundKey,S_Box);
            end
            Cell_Encryption_blue{i,j}=bitxor(Cell_Encryption_blue{i,j},Cel3);
            IV2=uint8(IV2);
            if reply=='D' || reply=='d' || reply == '3'
                IV_new=hex2dec(strcat(dec2hex(IV2(2,1),2),dec2hex(IV2(2,2),2),dec2hex(IV2(2,3),2),dec2hex(IV2(2,4),2)))+1;
                IV_new=dec2hex(IV_new,8);
                IV2(2,1)=hex2dec(strcat(IV_new(1,1),IV_new(1,2)));
                IV2(2,2)=hex2dec(strcat(IV_new(1,3),IV_new(1,4)));
                IV2(2,3)=hex2dec(strcat(IV_new(1,5),IV_new(1,6)));
                IV2(2,4)=hex2dec(strcat(IV_new(1,7),IV_new(1,8)));
            else
                IV_new=hex2dec(strcat(dec2hex(IV2(4,1),2),dec2hex(IV2(4,2),2),dec2hex(IV2(4,3),2),dec2hex(IV2(4,4),2)))+1;
                IV_new=dec2hex(IV_new,8);
                IV2(4,1)=hex2dec(strcat(IV_new(1,1),IV_new(1,2)));
                IV2(4,2)=hex2dec(strcat(IV_new(1,3),IV_new(1,4)));
                IV2(4,3)=hex2dec(strcat(IV_new(1,5),IV_new(1,6)));
                IV2(4,4)=hex2dec(strcat(IV_new(1,7),IV_new(1,8)));
            end
        end
    end
    Img_Decrypted_blue=cell2mat(Cell_Encryption_blue);
    Img_Decrypted_blue=imcrop(Img_Decrypted_blue,[0 0  SizeOfOriginalPic1(1,2) SizeOfOriginalPic1(1,1)]);
    
    Img_Encrypted_blue=uint8(Img_Encrypted_Blue);
    Img_Encrypted_red=uint8(Img_Encrypted_Red);
    Img_Encrypted_green=uint8(Img_Encrypted_Green);

    Img_Decrypted_blue=uint8(Img_Decrypted_blue);
    Img_Decrypted_red=uint8(Img_Decrypted_red);
    Img_Decrypted_green=uint8(Img_Decrypted_green);

    Img_Decrypted = cat(3,Img_Decrypted_red,Img_Decrypted_green,Img_Decrypted_blue);
    figure , subplot(1,5,1), imshow(Im),title('Orginal Image'),...
        subplot(1,5,2), imshow(Img_Encrypted_red),title('Encryp Red') ,...
        subplot(1,5,3), imshow(Img_Encrypted_green),title('Encryp Green'),...
        subplot(1,5,4), imshow(Img_Encrypted_blue),title('Encryp Blue') ,...
        subplot(1,5,5), imshow(Img_Decrypted),title('Decryp Image');

else
%   If Row & Column is not to 4 it should be resized

    SizeOfOriginalPic1=size(Im);
    I=resize(Im);
    SizeOfOriginalPic2=size(I);
    if reply=='d' || reply=='D'
        Rows=SizeOfOriginalPic2(1,1);    Rows=Rows/2;     Vector1(1:Rows)=2;
        Cols=SizeOfOriginalPic2(1,2);    Cols=Cols/4;     Vector2(1:Cols)=4;
        I=double(I);    %    The Image should be converted to double
        Cell=mat2cell(I,Vector1,Vector2);
        IV2=IV(1:2,:);
        for i=1:Rows
            for j=1:Cols
                IV2=double(IV2);
                Cel2=fun1(IV2,RoundKey);
                Cell{i,j}=bitxor(Cel2,Cell{i,j});
                IV2=uint8(IV2);
            
                %   incremnting the counter one number 
                IV_new=hex2dec(strcat(dec2hex(IV2(2,1),2),dec2hex(IV2(2,2),2),dec2hex(IV2(2,3),2),dec2hex(IV2(2,4),2)))+1;
                IV_new=dec2hex(IV_new,8);
                % concating 2 hexadecimal number then each 8-bit number is converted to decimal one
                IV2(2,1)=hex2dec(strcat(IV_new(1,1),IV_new(1,2)));
                IV2(2,2)=hex2dec(strcat(IV_new(1,3),IV_new(1,4)));
                IV2(2,3)=hex2dec(strcat(IV_new(1,5),IV_new(1,6)));
                IV2(2,4)=hex2dec(strcat(IV_new(1,7),IV_new(1,8)));
            end
        end
        Img_Encrypted=cell2mat(Cell);
        Cell_Encryption=mat2cell(Img_Encrypted,Vector1,Vector2);
        IV2=IV(1:2,:);
        for i=1:Rows
            for j=1:Cols
                IV2=double(IV2);
                Cel3=fun1(IV2,RoundKey);
                Cell_Encryption{i,j}=bitxor(Cell_Encryption{i,j},Cel3);
                IV2=uint8(IV2);
                IV_new=hex2dec(strcat(dec2hex(IV2(2,1),2),dec2hex(IV2(2,2),2),dec2hex(IV2(2,3),2),dec2hex(IV2(2,4),2)))+1;
                IV_new=dec2hex(IV_new,8);
                IV2(2,1)=hex2dec(strcat(IV_new(1,1),IV_new(1,2)));
                IV2(2,2)=hex2dec(strcat(IV_new(1,3),IV_new(1,4)));
                IV2(2,3)=hex2dec(strcat(IV_new(1,5),IV_new(1,6)));
                IV2(2,4)=hex2dec(strcat(IV_new(1,7),IV_new(1,8)));
            end
        end
    elseif reply=='3'
        Rows=SizeOfOriginalPic2(1,1);    Rows=Rows/2;     Vector1(1:Rows)=2;
        Cols=SizeOfOriginalPic2(1,2);    Cols=Cols/4;     Vector2(1:Cols)=4;
        I=double(I);    %    The Image should be converted to double
        Cell=mat2cell(I,Vector1,Vector2);
        IV2=IV(1:2,:);
        for i=1:Rows
            for j=1:Cols
                IV2=double(IV2);
                Cel2=fun1(IV2,RoundKey1,RoundKey2);
                Cell{i,j}=bitxor(Cel2,Cell{i,j});
                IV2=uint8(IV2);
            
                %   incremnting the counter one number 
                IV_new=hex2dec(strcat(dec2hex(IV2(2,1),2),dec2hex(IV2(2,2),2),dec2hex(IV2(2,3),2),dec2hex(IV2(2,4),2)))+1;
                IV_new=dec2hex(IV_new,8);
                % concating 2 hexadecimal number then each 8-bit number is converted to decimal one
                IV2(2,1)=hex2dec(strcat(IV_new(1,1),IV_new(1,2)));
                IV2(2,2)=hex2dec(strcat(IV_new(1,3),IV_new(1,4)));
                IV2(2,3)=hex2dec(strcat(IV_new(1,5),IV_new(1,6)));
                IV2(2,4)=hex2dec(strcat(IV_new(1,7),IV_new(1,8)));
            end
        end
        Img_Encrypted=cell2mat(Cell);
        Cell_Encryption=mat2cell(Img_Encrypted,Vector1,Vector2);
        IV2=IV(1:2,:);
        for i=1:Rows
            for j=1:Cols
                IV2=double(IV2);
                Cel3=fun1(IV2,RoundKey1,RoundKey2);
                Cell_Encryption{i,j}=bitxor(Cell_Encryption{i,j},Cel3);
                IV2=uint8(IV2);
                IV_new=hex2dec(strcat(dec2hex(IV2(2,1),2),dec2hex(IV2(2,2),2),dec2hex(IV2(2,3),2),dec2hex(IV2(2,4),2)))+1;
                IV_new=dec2hex(IV_new,8);
                IV2(2,1)=hex2dec(strcat(IV_new(1,1),IV_new(1,2)));
                IV2(2,2)=hex2dec(strcat(IV_new(1,3),IV_new(1,4)));
                IV2(2,3)=hex2dec(strcat(IV_new(1,5),IV_new(1,6)));
                IV2(2,4)=hex2dec(strcat(IV_new(1,7),IV_new(1,8)));
            end
        end
    else
        Rows=SizeOfOriginalPic2(1,1);    Rows=Rows/4;     Vector1(1:Rows)=4;
        Cols=SizeOfOriginalPic2(1,2);    Cols=Cols/4;     Vector2(1:Cols)=4;
        I=double(I);    %    The Image should be converted to double
        Cell=mat2cell(I,Vector1,Vector2);
        IV2=IV;
        for i=1:Rows
            for j=1:Cols
                IV2=double(IV2);
                Cel2=fun1(IV2,RoundKey,S_Box);
                Cell{i,j}=bitxor(Cel2,Cell{i,j});
                IV2=uint8(IV2);
            
                %   incremnting the counter one number 
                IV_new=hex2dec(strcat(dec2hex(IV2(4,1),2),dec2hex(IV2(4,2),2),dec2hex(IV2(4,3),2),dec2hex(IV2(4,4),2)))+1;
                IV_new=dec2hex(IV_new,8);
                % concating 2 hexadecimal number then each 8-bit number is converted to decimal one
                IV2(4,1)=hex2dec(strcat(IV_new(1,1),IV_new(1,2)));
                IV2(4,2)=hex2dec(strcat(IV_new(1,3),IV_new(1,4)));
                IV2(4,3)=hex2dec(strcat(IV_new(1,5),IV_new(1,6)));
                IV2(4,4)=hex2dec(strcat(IV_new(1,7),IV_new(1,8)));
            end
        end
        Img_Encrypted=cell2mat(Cell);
        Cell_Encryption=mat2cell(Img_Encrypted,Vector1,Vector2);
        IV2=IV;
        for i=1:Rows
            for j=1:Cols
                IV2=double(IV2);
                Cel3=fun1(IV2,RoundKey,S_Box);
                Cell_Encryption{i,j}=bitxor(Cell_Encryption{i,j},Cel3);
                IV2=uint8(IV2);
                IV_new=hex2dec(strcat(dec2hex(IV2(4,1),2),dec2hex(IV2(4,2),2),dec2hex(IV2(4,3),2),dec2hex(IV2(4,4),2)))+1;
                IV_new=dec2hex(IV_new,8);
                IV2(4,1)=hex2dec(strcat(IV_new(1,1),IV_new(1,2)));
                IV2(4,2)=hex2dec(strcat(IV_new(1,3),IV_new(1,4)));
                IV2(4,3)=hex2dec(strcat(IV_new(1,5),IV_new(1,6)));
                IV2(4,4)=hex2dec(strcat(IV_new(1,7),IV_new(1,8)));
            end
        end
    end
    %   Computing the NPCR
    disp('The NPCR between the Original Image & Encrypted Image :');    adad=NPCR(Im,Img_Encrypted);disp(adad);
    %   Computing the UACI
    disp('The UACI between the Original Image & Encrypted Image :');    adad=UACI(Im,Img_Encrypted);disp(adad);
    %   Computing the PSNR
    p = psnr(Im,Img_Encrypted);  disp('The PSNR between the Original Image & Encrypted Image :');disp(p);
    %   Computing the Correlation Coefficient
    Img_Encrypted2=double(Img_Encrypted);
    Im2=double(Im);
    disp('The Correlation Coefficient of the Original Image:');   
    x = Im2(:,1:end-1);  %# All rows and columns 1 through end-1
    y = Im2(:,2:end);    %# All rows and columns 2 through end
    h_xy_Im = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy_Im(1,2));
%     figure,plot(x(:),y(:)),title('Orginal Image')
    x = Im2(1:end-1,:);  %#  1 through end-1 rows and All columns 
    y = Im2(2:end,:);    %# 2 through end rows and All columns 
    v_xy_Im = corrcoef(x(:),y(:));     fprintf('Vertical is: %f\n',v_xy_Im(1,2));
       
    disp('The Correlation Coefficient Of Encrypted Image :');   
    x = Img_Encrypted2(:,1:end-1);  %# All rows and columns 1 through end-1
    y = Img_Encrypted2(:,2:end);    %# All rows and columns 2 through end
    h_xy = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy(1,2));
%     figure,plot(x(:),y(:)), title('Encrypted Image')
    x = Img_Encrypted2(1:end-1,:);  %#  1 through end-1 rows and All columns 
    y = Img_Encrypted2(2:end,:);    %# 2 through end rows and All columns 
    v_xy = corrcoef(x(:),y(:));     fprintf('Vertical is: %f\n',v_xy(1,2));

    Img_Decrypted=cell2mat(Cell_Encryption);
    Img_Decrypted=imcrop(Img_Decrypted,[0 0  SizeOfOriginalPic1(1,2) SizeOfOriginalPic1(1,1)]);
    Img_Encrypted_red=uint8(Img_Encrypted);
    Img_Encrypted_green=uint8(Img_Encrypted); 
    Img_Encrypted_blue=uint8(Img_Encrypted);
%     figure,subplot(1,3,1),imhist(Im),title('Orginal Image'),...
%            subplot(1,3,2),imhist(Img_Encrypted_blue),title('Encryp Img');
%            subplot(1,3,3),imhist(Img_Decrypted),title('Decryp Img');
    figure , subplot(1,3,1), imshow(Im),title('Orginal Image'),...
        subplot(1,3,2), imshow(Img_Encrypted_red),title('EncryptedImage') ,...
        subplot(1,3,3), imshow(Img_Decrypted),title('DecryptedImage');
end
tEnd = toc(tStart);
fprintf('%d minutes and %f seconds\n',floor(tEnd/60),rem(tEnd,60));