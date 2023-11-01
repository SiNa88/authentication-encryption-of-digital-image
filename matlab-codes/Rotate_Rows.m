function State_out=Rotate_Rows(State)
State_out(1:4,1:4)=0;
% First Row withOut Rotating
State_out(1,:)=State(1,[1 2 3 4]);

%Second Row with 1 Rotating to left
State_out(2,:)=State(2,[2 3 4 1]);

%Third Row with 2 Rotating to left
State_out(3,:)=State(3,[3 4 1 2]);

%Fourth Row with 3 Rotating to left
State_out(4,:)=State(4,[4 1 2 3]);