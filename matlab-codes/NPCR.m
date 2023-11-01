function OUT=NPCR(Im,Im_Encrypted)
OUT=0;
[ROW,COL]=size(Im);
%size(Im_Encrypted)
for i=1:ROW
    for j=1:COL
        if Im(i,j) == Im_Encrypted(i,j)
            OUT=OUT+0;
        elseif Im(i,j) ~= Im_Encrypted(i,j)
            OUT=OUT+1;
        end
        
    end
end
OUT=(OUT/(ROW*COL))*100;