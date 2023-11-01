function Rcon=R_Con(Num)
% The round constant is a word in which the three rightmost bytes are 
% always 0.
RC(1:10)=0;
RC(1)=1;
for i=2:8
    RC(i)=RC(i-1)*2;
end
RC(9)=27;RC(10)=54;
Rcon = [ RC(Num) 0 0 0 ]; %    Rcon[i] = (RC[i], 0, 0, 0)