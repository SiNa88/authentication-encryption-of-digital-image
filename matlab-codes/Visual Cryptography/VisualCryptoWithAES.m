function [Ared Agreen Ablue Img_Decrypted]=VisualCryptoWithAES(Im,key)
tStart = tic; 
Img_Decrypted=0;
warning off;
if isrgb(Im)
    %  Extract the individual red, green, and blue color channels.
    redChannel = Im(:, :, 1);
    redImg = jarvisHalftone(redChannel);
    [redshare1 redshare2]=visuaCrypto(redImg);
    [Img_Encrypted_red1 Img_Encrypted_red1 Img_Encrypted_red1 redImg_Decrypted1]=CTR22(redshare1,key);
    [Img_Encrypted_red2 Img_Encrypted_red2 Img_Encrypted_red2 redImg_Decrypted2]=CTR22(redshare2,key);
    redshare12=inversseVisuCrypto((redImg_Decrypted1),(redImg_Decrypted2));
    Ared = ROFdenoise(redshare12);
    
    greenChannel = Im(:, :, 2);
    greenImg = jarvisHalftone(greenChannel);
    [greenshare1 greenshare2]=visuaCrypto(greenImg);
    [Img_Encrypted_green1 Img_Encrypted_green1 Img_Encrypted_green1 greenImg_Decrypted1]=CTR22(greenshare1,key);
    [Img_Encrypted_green2 Img_Encrypted_green2 Img_Encrypted_green2 greenImg_Decrypted2]=CTR22(greenshare2,key);
    greenshare12=inversseVisuCrypto((greenImg_Decrypted1),(greenImg_Decrypted2));
    Agreen =ROFdenoise(greenshare12);
    
    blueChannel = Im(:, :, 3);
    blueImg = jarvisHalftone(blueChannel);
    [blueshare1 blueshare2]=visuaCrypto(blueImg);
    [Img_Encrypted_blue1 Img_Encrypted_blue1 Img_Encrypted_blue1 blueImg_Decrypted1]=CTR22(blueshare1,key);
    [Img_Encrypted_blue2 Img_Encrypted_blue2 Img_Encrypted_blue2 blueImg_Decrypted2]=CTR22(blueshare2,key);
    blueshare12=inversseVisuCrypto((blueImg_Decrypted1),(blueImg_Decrypted2));
    Ablue = ROFdenoise(blueshare12);
    
    Img_Decrypted = cat(3,Ared,Agreen,Ablue);
    figure,subplot(121),imshow(Im),subplot(122),imshow(Img_Decrypted);    
else
    
     if ~isbw(Im)
        Img = jarvisHalftone(Im);
     else
        Img=Im;
     end
    [share1 share2]=SharingImage2Parts(Img);
    [Img_Encrypted1 Img_Encrypted1 Img_Encrypted1 Img_Decrypted1]=CTR22(share1,key);
    [Img_Encrypted2 Img_Encrypted2 Img_Encrypted2 Img_Decrypted2]=CTR22(share2,key);
    share12=inversseVisuCrypto((Img_Decrypted1),(Img_Decrypted2));
    A_denoised = ROFdenoise(share12);
    Ared=A_denoised;
    Agreen=A_denoised;
    Ablue=A_denoised;
    figure,subplot(121),imshow(Im),subplot(122),imshow(A_denoised);    
end
tEnd = toc(tStart);
fprintf('%d minutes and %f seconds\n',floor(tEnd/60),rem(tEnd,60));