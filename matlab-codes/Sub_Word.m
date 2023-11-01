function State_out=Sub_Word(State_in,S_Box)

State_out(1,1:4)=0;

for u=1:4
    State_HexDec=dec2hex(State_in(1,u),2);
    State_out(1,u)=S_Box((hex2dec(State_HexDec(1,1))+1),(hex2dec(State_HexDec(1,2)))+1);
end