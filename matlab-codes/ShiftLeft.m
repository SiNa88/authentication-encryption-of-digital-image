function IV_Out=ShiftLeft(IV,Cell)
%   Shifting every cell of the 4*4 matrix to left
IV_Out(1,[1 2 3])=IV(1,[2 3 4]);IV_Out(1,4)=IV(2,1);
IV_Out(2,[1 2 3])=IV(2,[2 3 4]);IV_Out(2,4)=IV(3,1);
IV_Out(3,[1 2 3])=IV(3,[2 3 4]);IV_Out(3,4)=IV(4,1);
IV_Out(4,[1 2 3])=IV(4,[2 3 4]);IV_Out(4,4)=Cell;