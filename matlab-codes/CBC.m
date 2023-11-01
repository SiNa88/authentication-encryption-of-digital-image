function [Img_Encrypted_red Img_Encrypted_green Img_Encrypted_blue Img_Decrypted]=CBC(Im,key)
% [Img_Encrypted Img_Decrypted]
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
% n = 255;
% IV(1:4,1:4)= floor(n.*rand(4,4));
IV=[198    24   146   209;
    99    33    15     3;
    61   240    59    10;
   102   243    90    43];
IV=double(IV);

warning off;
%   Gray Or RGB
if isrgb(Im)
        
    %  Extract the individual red, green, and blue color channels.
    redChannel = Im(:, :, 1);
    greenChannel = Im(:, :, 2);
    blueChannel = Im(:, :, 3);
   
    %%%%%%%%%%%%  Red   %%%%%%%%%%
    SizeOfOriginalPic1=size(redChannel);
    IV(1,1)=SizeOfOriginalPic1(1,1);
    IV(1,2)=SizeOfOriginalPic1(1,2);
    IV=double(IV);
    %   If Row & Column is not to 4 it should be resized
    IRed=resize(redChannel);

    SizeOfOriginalPic2=size(IRed);
    if reply=='D' || reply=='d' || reply=='3'
        num=2;
    else
        num=4;
    end
    Rows=SizeOfOriginalPic2(1,1);    Rows=Rows/num;    Vector1(1:Rows)=num;
    Cols=SizeOfOriginalPic2(1,2);    Cols=Cols/4;    Vector2(1:Cols)=4;
    IRed=double(IRed);    %    The Image should be converted to double
    Cell=mat2cell(IRed,Vector1,Vector2);
    if reply=='D' || reply=='d'
        Cel2=bitxor(IV(1:2,:),Cell{1,1});
        Cell{1,1}=fun1(Cel2,RoundKey);
    elseif reply=='3'
        Cel2=bitxor(IV(1:2,:),Cell{1,1});
        Cell{1,1}=fun1(Cel2,RoundKey1,RoundKey2);
    else
        Cel2=bitxor(IV,Cell{1,1});
        Cell{1,1}=fun1(Cel2,RoundKey,S_Box);
    end
    for i=1:Rows
        for j=1:Cols
            if j~=1 % i~=1///i==1
                Cel2=bitxor(Cell{i,j},Cell{i,j-1});
                if reply=='D' || reply=='d'        
                    Cell{i,j}=fun1(Cel2,RoundKey);
                elseif reply=='3'
                    Cell{i,j}=fun1(Cel2,RoundKey1,RoundKey2);
                else
                    Cell{i,j}=fun1(Cel2,RoundKey,S_Box);
                end
            elseif i~=1 && j==1
                Cel2=bitxor(Cell{i,j},Cell{i-1,Cols});
                if reply=='D' || reply=='d'        
                    Cell{i,j}=fun1(Cel2,RoundKey);
                elseif reply=='3'
                    Cell{i,j}=fun1(Cel2,RoundKey1,RoundKey2);
                else
                    Cell{i,j}=fun1(Cel2,RoundKey,S_Box);
                end
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
    
    Cell_Decryption_red=mat2cell(Img_Encrypted_Red,Vector1,Vector2);
    if reply=='D' || reply=='d'
        Cel3=fun2(Cell_Decryption_red{1,1},RoundKey);
        CellDecryptionNewRed{1,1}=bitxor(IV(1:2,:),Cel3);
    elseif reply=='3'
        Cel3=fun2(Cell_Decryption_red{1,1},RoundKey1,RoundKey2);
        CellDecryptionNewRed{1,1}=bitxor(IV(1:2,:),Cel3);
    else
        Cel3=fun2(Cell_Decryption_red{1,1},RoundKey,Inv_S_Box);
        CellDecryptionNewRed{1,1}=bitxor(IV,Cel3);
    end
    
    for i=1:Rows
        for j=1:Cols
            if j~=1 % i~=1///i==1
                if reply=='D' || reply=='d'        
                    Cel3=fun2(Cell_Decryption_red{i,j},RoundKey);
                elseif reply=='3'
                    Cel3=fun2(Cell_Decryption_red{i,j},RoundKey1,RoundKey2);
                else
                    Cel3=fun2(Cell_Decryption_red{i,j},RoundKey,Inv_S_Box);
                end
                CellDecryptionNewRed{i,j}=bitxor(Cell_Decryption_red{i,j-1},Cel3);
            elseif i~=1 && j==1
                if reply=='D' || reply=='d'        
                    Cel3=fun2(Cell_Decryption_red{i,j},RoundKey);
                elseif reply=='3'
                    Cel3=fun2(Cell_Decryption_red{i,j},RoundKey1,RoundKey2);
                else
                    Cel3=fun2(Cell_Decryption_red{i,j},RoundKey,Inv_S_Box);
                end
                CellDecryptionNewRed{i,j}=bitxor(Cell_Decryption_red{i-1,Cols},Cel3);
            end
        end
    end
    Img_Decrypted_red=cell2mat(CellDecryptionNewRed);
    Img_Decrypted_red=imcrop(Img_Decrypted_red,[0 0  SizeOfOriginalPic1(1,2) SizeOfOriginalPic1(1,1)]);
    
    %%%%%%%%%%%%  Green   %%%%%%%%%%
    %   If Row & Column is not to 4 it should be resized
    IGreen=resize(greenChannel);
    
    IGreen=double(IGreen);    %    The Image should be converted to double
    Cell=mat2cell(IGreen,Vector1,Vector2);
    if reply=='D' || reply=='d'        
        Cel2=bitxor(IV(1:2,:),Cell{1,1});
    	Cell{1,1}=fun1(Cel2,RoundKey);
    elseif reply=='3'
        Cel2=bitxor(IV(1:2,:),Cell{1,1});
        Cell{1,1}=fun1(Cel2,RoundKey1,RoundKey2);
    else
        Cel2=bitxor(IV,Cell{1,1});
        Cell{1,1}=fun1(Cel2,RoundKey,S_Box);
    end
    for i=1:Rows
        for j=1:Cols
            if j~=1 % i~=1///i==1
                Cel2=bitxor(Cell{i,j},Cell{i,j-1});
                if reply=='D' || reply=='d'        
                    Cell{i,j}=fun1(Cel2,RoundKey);
                elseif reply=='3'
                    Cell{i,j}=fun1(Cel2,RoundKey1,RoundKey2);
                else
                    Cell{i,j}=fun1(Cel2,RoundKey,S_Box);
                end
            elseif i~=1 && j==1
                Cel2=bitxor(Cell{i,j},Cell{i-1,Cols});
                if reply=='D' || reply=='d'        
                    Cell{i,j}=fun1(Cel2,RoundKey);
                elseif reply=='3'
                    Cell{i,j}=fun1(Cel2,RoundKey1,RoundKey2);
                else
                    Cell{i,j}=fun1(Cel2,RoundKey,S_Box);
                end
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
    disp('The Correlation Coefficient of the green Component of Original Image:');   
    x = Im2(:,1:end-1);  %# All rows and columns 1 through end-1
    y = Im2(:,2:end);    %# All rows and columns 2 through end
    h_xy_Im = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy_Im(1,2));
    
%     x = Im2(1:end-1,:);  %#  1 through end-1 rows and All columns 
%     y = Im2(2:end,:);    %# 2 through end rows and All columns 
%     v_xy_Im = corrcoef(x(:),y(:));     fprintf('Vertical is: %f\n',v_xy_Im(1,2));
    
    disp('The Correlation Coefficient Of Encrypted Image :');   
    x = Img_Encrypted2(:,1:end-1);  %# All rows and columns 1 through end-1
    y = Img_Encrypted2(:,2:end);    %# All rows and columns 2 through end
    h_xy = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy(1,2));
    
%     x = Img_Encrypted2(1:end-1,:);  %#  1 through end-1 rows and All columns 
%     y = Img_Encrypted2(2:end,:);    %# 2 through end rows and All columns 
%     v_xy = corrcoef(x(:),y(:));     fprintf('Vertical is: %f\n',v_xy(1,2));
    Cell_Decryption_green=mat2cell(Img_Encrypted_Green,Vector1,Vector2);
    if reply=='D' || reply=='d'
        Cel3=fun2(Cell_Decryption_green{1,1},RoundKey);
        CellDecryptionNewGreen{1,1}=bitxor(IV(1:2,:),Cel3);
    elseif reply=='3'
        Cel3=fun2(Cell_Decryption_green{1,1},RoundKey1,RoundKey2);
        CellDecryptionNewGreen{1,1}=bitxor(IV(1:2,:),Cel3);
    else
        Cel3=fun2(Cell_Decryption_green{1,1},RoundKey,Inv_S_Box);
        CellDecryptionNewGreen{1,1}=bitxor(IV,Cel3);
    end
    for i=1:Rows
        for j=1:Cols
            if j~=1 % i~=1///i==1
                if reply=='D' || reply=='d'        
                    Cel3=fun2(Cell_Decryption_green{i,j},RoundKey);
                elseif reply=='3'
                    Cel3=fun2(Cell_Decryption_green{i,j},RoundKey1,RoundKey2);
                else
                    Cel3=fun2(Cell_Decryption_green{i,j},RoundKey,Inv_S_Box);
                end
                CellDecryptionNewGreen{i,j}=bitxor(Cell_Decryption_green{i,j-1},Cel3);
            elseif i~=1 && j==1
                if reply=='D' || reply=='d'        
                    Cel3=fun2(Cell_Decryption_green{i,j},RoundKey);
                elseif reply=='3'
                    Cel3=fun2(Cell_Decryption_green{i,j},RoundKey1,RoundKey2);
                else
                    Cel3=fun2(Cell_Decryption_green{i,j},RoundKey,Inv_S_Box);
                end
                CellDecryptionNewGreen{i,j}=bitxor(Cell_Decryption_green{i-1,Cols},Cel3);
            end
        end
    end
    Img_Decrypted_green=cell2mat(CellDecryptionNewGreen);
    Img_Decrypted_green=imcrop(Img_Decrypted_green,[0 0  SizeOfOriginalPic1(1,2) SizeOfOriginalPic1(1,1)]);
    
    %%%%%%%%%%%%  Blue  %%%%%%%%%%
    %   If Row & Column is not to 4 it should be resized
    IBlue=resize(blueChannel);
    IBlue=double(IBlue);    %    The Image should be converted to double
    Cell=mat2cell(IBlue,Vector1,Vector2);
    if reply=='D' || reply=='d'        
        Cel2=bitxor(IV(1:2,:),Cell{1,1});
    	Cell{1,1}=fun1(Cel2,RoundKey);
    elseif reply=='3'
        Cel2=bitxor(IV(1:2,:),Cell{1,1});
        Cell{1,1}=fun1(Cel2,RoundKey1,RoundKey2);
    else
        Cel2=bitxor(IV,Cell{1,1});
        Cell{1,1}=fun1(Cel2,RoundKey,S_Box);
    end
    
    for i=1:Rows
        for j=1:Cols
            if j~=1 % i~=1///i==1
                Cel2=bitxor(Cell{i,j},Cell{i,j-1});
                if reply=='D' || reply=='d'        
                    Cell{i,j}=fun1(Cel2,RoundKey);
                elseif reply=='3'
                    Cell{i,j}=fun1(Cel2,RoundKey1,RoundKey2);
                else
                    Cell{i,j}=fun1(Cel2,RoundKey,S_Box);
                end
            elseif i~=1 && j==1
                Cel2=bitxor(Cell{i,j},Cell{i-1,Cols});
                if reply=='D' || reply=='d'        
                    Cell{i,j}=fun1(Cel2,RoundKey);
                elseif reply=='3'
                    Cell{i,j}=fun1(Cel2,RoundKey1,RoundKey2);
                else
                    Cell{i,j}=fun1(Cel2,RoundKey,S_Box);
                end
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
    Cell_Decryption_blue=mat2cell(Img_Encrypted_Blue,Vector1,Vector2);
    if reply=='D' || reply=='d'
        Cel3=fun2(Cell_Decryption_blue{1,1},RoundKey);
        CellDecryptionNewBlue{1,1}=bitxor(IV(1:2,:),Cel3);
    elseif reply=='3'
        Cel3=fun2(Cell_Decryption_blue{1,1},RoundKey1,RoundKey2);
        CellDecryptionNewBlue{1,1}=bitxor(IV(1:2,:),Cel3);
    else
        Cel3=fun2(Cell_Decryption_blue{1,1},RoundKey,Inv_S_Box);
        CellDecryptionNewBlue{1,1}=bitxor(IV,Cel3);
    end
    for i=1:Rows
        for j=1:Cols
            if j~=1 % i~=1///i==1
                if reply=='D' || reply=='d'        
                    Cel3=fun2(Cell_Decryption_blue{i,j},RoundKey);
                elseif reply=='3'
                    Cel3=fun2(Cell_Decryption_blue{i,j},RoundKey1,RoundKey2);
                else
                    Cel3=fun2(Cell_Decryption_blue{i,j},RoundKey,Inv_S_Box);
                end
                CellDecryptionNewBlue{i,j}=bitxor(Cell_Decryption_blue{i,j-1},Cel3);
            elseif i~=1 && j==1
                if reply=='D' || reply=='d'        
                    Cel3=fun2(Cell_Decryption_blue{i,j},RoundKey);
                elseif reply=='3'
                    Cel3=fun2(Cell_Decryption_blue{i,j},RoundKey1,RoundKey2);
                else
                    Cel3=fun2(Cell_Decryption_blue{i,j},RoundKey,Inv_S_Box);
                end
                CellDecryptionNewBlue{i,j}=bitxor(Cell_Decryption_blue{i-1,Cols},Cel3);
            end
        end
    end
    Img_Decrypted_blue=cell2mat(CellDecryptionNewBlue);
    Img_Decrypted_blue=imcrop(Img_Decrypted_blue,[0 0  SizeOfOriginalPic1(1,2) SizeOfOriginalPic1(1,1)]);
    
    Img_Encrypted_blue=uint8(Img_Encrypted_Blue);
    Img_Encrypted_red=uint8(Img_Encrypted_Red);
    Img_Encrypted_green=uint8(Img_Encrypted_Green);

    Img_Decrypted_blue=uint8(Img_Decrypted_blue);
    Img_Decrypted_red=uint8(Img_Decrypted_red);
    Img_Decrypted_green=uint8(Img_Decrypted_green);

    Img_Decrypted = cat(3,Img_Decrypted_red,Img_Decrypted_green,Img_Decrypted_blue);
    figure , subplot(1,5,1), imshow(Im),title('Orginal Image'),...
        subplot(1,5,2), imshow(Img_Encrypted_red),title('Encryp RedComponent') ,...
        subplot(1,5,3), imshow(Img_Encrypted_green),title('Encryp GreenComponent'),...
        subplot(1,5,4), imshow(Img_Encrypted_blue),title('Encryp BlueComponent') ,...
        subplot(1,5,5), imshow(Img_Decrypted),title('Decryp Image');

else
%   If Row & Column is not to 4 it should be resized

    SizeOfOriginalPic1=size(Im);
    I=resize(Im);
    SizeOfOriginalPic2=size(I);
    if reply=='d' || reply=='D'
        Rows=SizeOfOriginalPic2(1,1);    Rows=Rows/2; Vector1(1:Rows)=2;
        Cols=SizeOfOriginalPic2(1,2);    Cols=Cols/4; Vector2(1:Cols)=4;
        I=double(I);    %    The Image should be converted to double
        Cell=mat2cell(I,Vector1,Vector2);
        Cel2=bitxor(IV(1:2,:),Cell{1,1});
        Cell{1,1}=fun1(Cel2,RoundKey);
        for i=1:Rows
            for j=1:Cols
                if j~=1 % i~=1///i==1
                    Cel2=bitxor(Cell{i,j},Cell{i,j-1});
                    Cell{i,j}=fun1(Cel2,RoundKey);
                elseif i~=1 && j==1
                    Cel2=bitxor(Cell{i,j},Cell{i-1,Cols});
                    Cell{i,j}=fun1(Cel2,RoundKey);
                end
            end
        end
        Img_Encrypted=cell2mat(Cell);
        Cell_Decryption=mat2cell(Img_Encrypted,Vector1,Vector2);
        Cel3=fun2(Cell_Decryption{1,1},RoundKey);
        CellDecryptionNew{1,1}=bitxor(IV(1:2,:),Cel3);    %CellDecryptionNew{1,1}=Cel3;
        for i=1:Rows
            for j=1:Cols
                if j~=1 % i~=1///i==1
                    Cel3=fun2(Cell_Decryption{i,j},RoundKey);
                    CellDecryptionNew{i,j}=bitxor(Cell_Decryption{i,j-1},Cel3);
                elseif i~=1 && j==1
                    Cel3=fun2(Cell_Decryption{i,j},RoundKey);
                    CellDecryptionNew{i,j}=bitxor(Cell_Decryption{i-1,Cols},Cel3);
                end
            end
        end
    elseif reply =='3'
        Rows=SizeOfOriginalPic2(1,1);    Rows=Rows/2;
        Cols=SizeOfOriginalPic2(1,2);    Cols=Cols/4;
        Vector1(1:Rows)=2;
        Vector2(1:Cols)=4;
        I=double(I);    %    The Image should be converted to double
        Cell=mat2cell(I,Vector1,Vector2);
        Cel2=bitxor(IV(1:2,:),Cell{1,1});
        Cell{1,1}=fun1(Cel2,RoundKey1,RoundKey2);
        for i=1:Rows
            for j=1:Cols
                if j~=1 % i~=1///i==1
                    Cel2=bitxor(Cell{i,j},Cell{i,j-1});
                    Cell{i,j}=fun1(Cel2,RoundKey1,RoundKey2);
                elseif i~=1 && j==1
                    Cel2=bitxor(Cell{i,j},Cell{i-1,Cols});
                    Cell{i,j}=fun1(Cel2,RoundKey1,RoundKey2);
                end
            end
        end
        Img_Encrypted=cell2mat(Cell);
        Cell_Decryption=mat2cell(Img_Encrypted,Vector1,Vector2);
        Cel3=fun2(Cell_Decryption{1,1},RoundKey1,RoundKey2);
        CellDecryptionNew{1,1}=bitxor(IV(1:2,:),Cel3);    %CellDecryptionNew{1,1}=Cel3;
        for i=1:Rows
            for j=1:Cols
                if j~=1 % i~=1///i==1
                    Cel3=fun2(Cell_Decryption{i,j},RoundKey1,RoundKey2);
                    CellDecryptionNew{i,j}=bitxor(Cell_Decryption{i,j-1},Cel3);
                elseif i~=1 && j==1
                    Cel3=fun2(Cell_Decryption{i,j},RoundKey1,RoundKey2);
                    CellDecryptionNew{i,j}=bitxor(Cell_Decryption{i-1,Cols},Cel3);
                end
             end
        end
    else
        Rows=SizeOfOriginalPic2(1,1);    Rows=Rows/4;
        Cols=SizeOfOriginalPic2(1,2);    Cols=Cols/4;
        Vector1(1:Rows)=4;
        Vector2(1:Cols)=4;
        I=double(I);    %    The Image should be converted to double
        Cell=mat2cell(I,Vector1,Vector2);
        Cel2=bitxor(IV,Cell{1,1});
        Cell{1,1}=fun1(Cel2,RoundKey,S_Box);
        for i=1:Rows
            for j=1:Cols
                if j~=1 % i~=1///i==1
                    Cel2=bitxor(Cell{i,j},Cell{i,j-1});
                    Cell{i,j}=fun1(Cel2,RoundKey,S_Box);
                elseif i~=1 && j==1
                    Cel2=bitxor(Cell{i,j},Cell{i-1,Cols});
                    Cell{i,j}=fun1(Cel2,RoundKey,S_Box);
                end
            end
        end
        Img_Encrypted=cell2mat(Cell);
        Cell_Decryption=mat2cell(Img_Encrypted,Vector1,Vector2);
        Cel3=fun2(Cell_Decryption{1,1},RoundKey,Inv_S_Box);
        CellDecryptionNew{1,1}=bitxor(IV,Cel3);    %CellDecryptionNew{1,1}=Cel3;
        for i=1:Rows
            for j=1:Cols
                if j~=1 % i~=1///i==1
                    Cel3=fun2(Cell_Decryption{i,j},RoundKey,Inv_S_Box);
                    CellDecryptionNew{i,j}=bitxor(Cell_Decryption{i,j-1},Cel3);
                elseif i~=1 && j==1
                    Cel3=fun2(Cell_Decryption{i,j},RoundKey,Inv_S_Box);
                    CellDecryptionNew{i,j}=bitxor(Cell_Decryption{i-1,Cols},Cel3);
                end
             end
        end
    end
%     %   Computing the NPCR
%     disp('The NPCR between the Original Image & Encrypted Image :');    adad=NPCR(double(Im),Img_Encrypted);disp(adad);
%     %   Computing the UACI
%     disp('The UACI between the Original Image & Encrypted Image :');    adad=UACI(double(Im),Img_Encrypted);disp(adad);
%     %   Computing the PSNR
%     p = psnr(Im,Img_Encrypted);  disp('The PSNR between the Original Image & Encrypted Image :');disp(p);
%     %   Computing the Correlation Coefficient
%     Img_Encrypted2=double(Img_Encrypted);
%     Im2=double(Im);
%     disp('The Correlation Coefficient of the Original Image:');   
%     x = Im2(:,1:end-1);  %# All rows and columns 1 through end-1
%     y = Im2(:,2:end);    %# All rows and columns 2 through end
%     h_xy_Im = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy_Im(1,2));
%     
%     x = Im2(1:end-1,:);  %#  1 through end-1 rows and All columns 
%     y = Im2(2:end,:);    %# 2 through end rows and All columns 
%     v_xy_Im = corrcoef(x(:),y(:));     fprintf('Vertical is: %f\n',v_xy_Im(1,2));
%     
%     disp('The Correlation Coefficient Of Encrypted Image :');   
%     x = Img_Encrypted2(:,1:end-1);  %# All rows and columns 1 through end-1
%     y = Img_Encrypted2(:,2:end);    %# All rows and columns 2 through end
%     h_xy = corrcoef(x(:),y(:));     fprintf('Horizental is: %f\n',h_xy(1,2));
%     
%     x = Img_Encrypted2(1:end-1,:);  %#  1 through end-1 rows and All columns 
%     y = Img_Encrypted2(2:end,:);    %# 2 through end rows and All columns 
%     v_xy = corrcoef(x(:),y(:));     fprintf('Vertical is: %f\n',v_xy(1,2));

    Img_Decrypted=cell2mat(CellDecryptionNew);
    Img_Decrypted=uint8(imcrop(Img_Decrypted,[0 0  SizeOfOriginalPic1(1,2) SizeOfOriginalPic1(1,1)]));
    Img_Encrypted_red=uint8(Img_Encrypted);
    Img_Encrypted_green=uint8(Img_Encrypted); 
    Img_Encrypted_blue=uint8(Img_Encrypted);
%     figure,subplot(131),imhist(Im),title('Orginal Image'),...
%             subplot(132),imhist(Img_Encrypted_blue),title('Encryp Img');
%             subplot(133),imhist(Img_Decrypted),title('Decryp Img');
%     figure , subplot(1,3,1), imshow(Im),title('Orginal Image'),...
%     subplot(1,3,2), imshow(uint8(Img_Encrypted)),title('Encrypted Image') ,...
%     subplot(1,3,3), imshow(Img_Decrypted),title('Decrypted Image');
end
tEnd = toc(tStart);
fprintf('%d minutes and %f seconds\n',floor(tEnd/60),rem(tEnd,60));