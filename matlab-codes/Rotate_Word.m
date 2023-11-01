function State_out=Rotate_Word(State_in)
%This Function Rotate the colunm From Down To Up This is Equal 2 Rotating
%From Left One Byte
%State_out(1,:)=0;
%disp(size(State_in));
State_out=State_in(1,[2 3 4 1]);
%disp(State_out);