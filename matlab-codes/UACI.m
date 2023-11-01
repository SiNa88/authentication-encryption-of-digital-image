function OUT=UACI(Im,Im_Encrypted)
%%%%% Unified Average Changing Intensity %%%%%
[ROW COL]=size(Im);
Im_Encrypted=Im_Encrypted(ROW,COL);
d = mean( mean( Im(:)-Im_Encrypted(:) ));
OUT=(d/(255))*100;