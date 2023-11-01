function [Img_Encrypted_Red Img_Encrypted_Green Img_Encrypted_Blue Img_Decrypted]=ECB(Im,key)

tStart = tic; 
disp('Which BlockCipher Algorithm do u want? AES/Serpent/DES/3-DES');
reply = input(' if AES press A else press S? A/S/D/3 [A]: ', 's');
if isempty(reply)
    reply='A';
end


% % %   The Block Cipher Algorithm is selected
% % %   Create the S-box and the inverse S-box & 
% % %   the expanded key (schedule)
if reply == 'A' || reply == 'a'
    [S_Box   Inv_S_Box   RoundKey]=AES_Initializing(key);
    fun1=@AES_Encryption;
    fun2=@AES_Decryption;
elseif reply == 'S' || reply == 's'
    [S_Box  Inv_S_Box    RoundKey]=Serpent_Initializing(key);
    fun1=@Serpent_Encryption;
    fun2=@Serpent_Decryption;
elseif reply == 'D' || reply == 'd'
    RoundKey=KeyExpansion_DES(key(1:2,:));
    fun1=@DES_Encryption;
    fun2=@DES_Decryption;
elseif reply == '3'
    RoundKey1=KeyExpansion_DES(key(1:2,:));
    RoundKey2=KeyExpansion_DES(key(3:4,:));
    fun1=@TripleDES;
    fun2=@TripleDES_Decryption;
else
    [S_Box   Inv_S_Box   RoundKey]=AES_Initializing(key);
    fun1=@AES_Encryption;
    fun2=@AES_Decryption;
end

warning off;
%   Gray Or RGB
if isrgb(Im)
    
    %  Extract the individual red, green, and blue color channels.
    redChannel = Im(:, :, 1);
    greenChannel = Im(:, :, 2);
    blueChannel = Im(:, :, 3);
   
    %%%%%%%%%%%%  Red   %%%%%%%%%%%%
    %   If Row & Column is not to 4 it should be resized
    Size_Original_Pic=size(redChannel);
    IRed=resize(redChannel);

    %   The Image should be converted to double
    IRed=double(IRed);
    %   Image is Broken to Blocks & each block is encrypted
    %   B = BLKPROC(A,[M N],FUN) => Distinct block processing for image.
    
    if reply=='D' || reply=='d'
        Img_Encrypted_Red = blkproc(IRed,[2 4],fun1,RoundKey);
        Img_Decrypted_red = blkproc(Img_Encrypted_Red ,[2 4],fun2,RoundKey);
    elseif reply=='3'
        Img_Encrypted_Red = blkproc(IRed,[2 4],fun1,RoundKey1,RoundKey2);
        Img_Decrypted_red = blkproc(Img_Encrypted_Red ,[2 4],fun2,RoundKey1,RoundKey2);
    else
        Img_Encrypted_Red = blkproc(IRed,[4 4],fun1,RoundKey,S_Box);
        Img_Decrypted_red = blkproc(Img_Encrypted_Red,[4 4],fun2,RoundKey,Inv_S_Box);
    end
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
    
    Img_Decrypted_red=imcrop(Img_Decrypted_red,[0 0  Size_Original_Pic(1,2) Size_Original_Pic(1,1)]);
    
    %%%%%%%%%%%%%%% Green  %%%%%%%%%%%%%%%
    
    %   If Row & Column is not to 4 it should be resized
    Size_Original_Pic=size(greenChannel);
    IGreen=resize(greenChannel);
    
    %   The Image should be converted to double
    IGreen=double(IGreen);
    if reply=='D' || reply=='d'
        Img_Encrypted_Green = blkproc(IGreen,[2 4],fun1,RoundKey);
        Img_Decrypted_green = blkproc(Img_Encrypted_Green ,[2 4],fun2,RoundKey);
    elseif reply=='3'
        Img_Encrypted_Green = blkproc(IGreen,[2 4],fun1,RoundKey1,RoundKey2);
        Img_Decrypted_green = blkproc(Img_Encrypted_Green ,[2 4],fun2,RoundKey1,RoundKey2);
    else
        Img_Encrypted_Green = blkproc(IGreen,[4 4],fun1,RoundKey,S_Box);
        Img_Decrypted_green = blkproc(Img_Encrypted_Green,[4 4],fun2,RoundKey,Inv_S_Box);
    end
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
    
    disp('The Correlation Coefficient Of Encrypted Image :');   
    x = Img_Encrypted2(:,1:end-1);  %# All rows and columns 1 through end-1
    y = Img_Encrypted2(:,2:end);    %# All rows and columns 2 through end
    h_xy = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy(1,2));
    
    Img_Decrypted_green=imcrop(Img_Decrypted_green,[0 0  Size_Original_Pic(1,2) Size_Original_Pic(1,1)]);

    %%%%%%%%%%%%%%%  Blue  %%%%%%%%%%%%%%
    
    %   If Row & Column is not to 4 it should be resized
    Size_Original_Pic=size(blueChannel);
    IBlue=resize(blueChannel);

    %   The Image should be converted to double
    IBlue=double(IBlue);
    if reply=='D' || reply=='d'
        Img_Encrypted_Blue = blkproc(IBlue,[2 4],fun1,RoundKey);
        Img_Decrypted_blue = blkproc(Img_Encrypted_Blue ,[2 4],fun2,RoundKey);
    elseif reply=='3'
        Img_Encrypted_Blue = blkproc(IBlue,[2 4],fun1,RoundKey1,RoundKey2);
        Img_Decrypted_blue= blkproc(Img_Encrypted_Blue ,[2 4],fun2,RoundKey1,RoundKey2);
    else
        Img_Encrypted_Blue = blkproc(IBlue,[4 4],fun1,RoundKey,S_Box);
        Img_Decrypted_blue = blkproc(Img_Encrypted_Blue,[4 4],fun2,RoundKey,Inv_S_Box);
    end
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
    
    disp('The Correlation Coefficient Of Encrypted Image :');   
    x = Img_Encrypted2(:,1:end-1);  %# All rows and columns 1 through end-1
    y = Img_Encrypted2(:,2:end);    %# All rows and columns 2 through end
    h_xy = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy(1,2));
    
    Img_Decrypted_blue=imcrop(Img_Decrypted_blue,[0 0  Size_Original_Pic(1,2) Size_Original_Pic(1,1)]);

    Img_Decrypted_blue=uint8(Img_Decrypted_blue);
    Img_Decrypted_red=uint8(Img_Decrypted_red);
    Img_Decrypted_green=uint8(Img_Decrypted_green);
    
    Img_Decrypted = cat(3,Img_Decrypted_red,Img_Decrypted_green,Img_Decrypted_blue);
    
    figure , subplot(1,5,1), imshow(Im),title('Orginal Image'),...
        subplot(1,5,2), imshow(Img_Encrypted_Red,[]),title('Encrypt(RedCompon)') ,...
        subplot(1,5,3), imshow(Img_Encrypted_Green,[]),title('Encrypt(GreenCompon)'),...
        subplot(1,5,4), imshow(Img_Encrypted_Blue,[]),title('Encryp(BlueCompon)') ,...
        subplot(1,5,5), imshow(Img_Decrypted,[]),title('DecryptImage');

else
    
    %   If Row & Column is not to 4 it should be resized
    %   I=resize(Im);
    SizeOfOriginalPic=size(Im);
    %   The Image should be converted to double
    I=double(Im);
    
	%   Image is Broken to Blocks & each block is encrypted
	%   B = BLKPROC(A,[M N],FUN) => Distinct block processing for
	%   image.
    if reply=='D' || reply=='d'
        Img_Encrypted = blkproc(I,[2 4],fun1,RoundKey);
        Img_Decrypted = blkproc(Img_Encrypted,[2 4],fun2,RoundKey);
    elseif reply=='3'
        Img_Encrypted = blkproc(I,[2 4],fun1,RoundKey1,RoundKey2);
        Img_Decrypted = blkproc(Img_Encrypted,[2 4],fun2,RoundKey1,RoundKey2);
    else
        Img_Encrypted = blkproc(I,[4 4],fun1,RoundKey,S_Box);
        Img_Decrypted = blkproc(Img_Encrypted,[4 4],fun2,RoundKey,Inv_S_Box);
    end
%     
%     %   Computing the NPCR
%     disp('The NPCR between the Original Image & Encrypted Image :');    adad=NPCR(Im,Img_Encrypted);disp(adad);
%     
%     %   Computing the UACI
%     disp('The UACI between the Original Image & Encrypted Image :');    adad=UACI(Im,Img_Encrypted);disp(adad);
%     
%     %   Computing the PSNR
%     p = psnr(Im,Img_Encrypted);  disp('The PSNR between the Original Image & Encrypted Image :');disp(p);
%     
%     %   Computing the Correlation Coefficient
%     Img_Encrypted2=double(Img_Encrypted);
%     Im2=double(Im);
%     disp('The Correlation Coefficient of the Original Image:');   
%     x = Im2(:,1:end-1);  %# All rows and columns 1 through end-1
%     y = Im2(:,2:end);    %# All rows and columns 2 through end
%     h_xy_Im = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy_Im(1,2));
%     
% %     x = Img_Encrypted2(1:end-1,:);  %#  1 through end-1 rows and All columns 
% %     y = Img_Encrypted2(2:end,:);    %# 2 through end rows and All columns 
% %     v_xy_Im = corrcoef(x(:),y(:));     fprintf('Vertical is: %f\n',v_xy_Im(1,2));
%     
%     disp('The Correlation Coefficient Of Encrypted Image :');   
%     x = Img_Encrypted2(:,1:end-1);  %# All rows and columns 1 through end-1
%     y = Img_Encrypted2(:,2:end);    %# All rows and columns 2 through end
%     h_xy = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy(1,2));
%     
% %     x = Img_Encrypted2(1:end-1,:);  %#  1 through end-1 rows and All columns 
% %     y = Img_Encrypted2(2:end,:);    %# 2 through end rows and All columns 
% %     v_xy = corrcoef(x(:),y(:));     fprintf('Vertical is: %f\n',v_xy(1,2));
%     
    Img_Decrypted=imcrop(Img_Decrypted,[0 0  SizeOfOriginalPic(1,2) SizeOfOriginalPic(1,1)]);
    Img_Encrypted_Red=Img_Encrypted;
    Img_Encrypted_Green=Img_Encrypted;
    Img_Encrypted_Blue=Img_Encrypted;
%     figure,subplot(131),imhist(Im),title('Orginal Image'),...
%             subplot(132),imhist(uint8(Img_Encrypted_Blue)),title('Encryp Img');
%             subplot(133),imhist(uint8(Img_Decrypted)),title('Decryp Img');
%     figure , subplot(1,3,1), imshow(Im),title('Orginal Image'),...
%         subplot(1,3,2), imshow(Img_Encrypted,[]),title('Encrypted Image') ,...
%         subplot(1,3,3), imshow(Img_Decrypted,[]),title('Decrypted Image');
end
tEnd = toc(tStart);
fprintf('%d minutes and %f seconds\n',floor(tEnd/60),rem(tEnd,60));