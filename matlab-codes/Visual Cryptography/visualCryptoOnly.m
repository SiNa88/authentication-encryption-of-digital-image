function A=visualCryptoOnly(Im)
if isrgb(Im)
    %  Extract the individual red, green, and blue color channels.
    redChannel = Im(:, :, 1);
    outImg = jarvisHalftone(redChannel);
    redImg =outImg;
    [redshare1 redshare2]=visuaCrypto(redImg);
    redshare12=inversseVisuCrypto(redshare1,redshare2);
    Ared = ROFdenoise(redshare12);
    
    greenChannel = Im(:, :, 2);
    outImg = jarvisHalftone(greenChannel);
    greenImg = outImg;
    [greenshare1 greenshare2]=visuaCrypto(greenImg);
    greenshare12=inversseVisuCrypto(greenshare1,greenshare2);
    Agreen =ROFdenoise(greenshare12);
    
    blueChannel = Im(:, :, 3);
    outImg = jarvisHalftone(blueChannel);
    blueImg = outImg;
    [blueshare1 blueshare2]=visuaCrypto(blueImg);
    blueshare12=inversseVisuCrypto(blueshare1,blueshare2);
    Ablue = ROFdenoise(blueshare12);
    
    Img_Decrypted = cat(3,Ared,Agreen,Ablue);
    A=Img_Decrypted;
    figure,subplot(121),imshow(Im),subplot(122),imshow(Img_Decrypted);     
else
    outImg = jarvisHalftone(Im);
    redImg = outImg ;
    [redshare1 redshare2]=visuaCrypto(redImg);
    redshare12=inversseVisuCrypto(redshare1,redshare2);
    A = ROFdenoise(redshare12);
    figure,subplot(121),imshow(Im),subplot(122),imshow(A); 
end