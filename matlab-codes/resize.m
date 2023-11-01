function Img=resize(Img)
[Row Col]=size(Img);
if mod( Row , 4) ~= 0
    modeR=mod( Row , 4 );
    if mod( Col , 4) ~= 0
        modeC=mod( Col , 4 );
        for i=Row+1:(Row+4-modeR)
            for j=Col+1:(Col+4-modeC)
                if i==Row+1 && j==Col+1
                    Img(i,j)=128;
                else
                    Img(i,j)=0;
                end
            end
        end
        for i=1:(Row+4-modeR)
            for j=Col+1:(Col+4-modeC)
                if i==1 && j==Col+1
                    Img(i,j)=128;
                else
                    Img(i,j)=0;
                end
            end
        end
        for i=Row+1:(Row+4-modeR)
            for j=1:(Col+4-modeC)
                if i==Row+1 && j==1
                    Img(i,j)=128;
                else
                    Img(i,j)=0;
                end
            end
        end
    else
       for i=Row+1:(Row+4-modeR)
            for j=1:(Col)
                if i==Row+1 && j==1
                    Img(i,j)=128;
                else
                    Img(i,j)=0;
                end
            end
       end
    end
else
    if mod( Col , 4) ~= 0
        modeC=mod( Col , 4 );
        for i=1:(Row)
            for j=Col+1:(Col+4-modeC)
                if i==1 && j==Col+1
                    Img(i,j)=128;
                else
                    Img(i,j)=0;
                end
            end
        end
    end
end