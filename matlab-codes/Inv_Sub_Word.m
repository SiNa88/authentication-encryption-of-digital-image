function State_out=Inv_Sub_Word(State_in,S_Box_Inv)
% % % C=[1 0 1 0 0 0 0 0];
% % % C=reshape(C,8,1);
% % % Mul(1:8,1:8)=0;
% % % Mul(1,1:8)=[0 0 1 0 0 1 0 1];
% % % for k=2:8
% % %     Mul(k,:)=circshift(Mul(k-1,:),[0 1]);
% % % end
% % % %disp(Mul);
State_out(1,1:4)=0;
for u=1:4
    State_Hexa=dec2hex(State_in(1,u),2);
    State_out(1,u)=S_Box_Inv((hex2dec(State_Hexa(1,1))+1),(hex2dec(State_Hexa(1,2)))+1);
% % %     State_HexDec=dec2hex(State_in,2);
% % %     if State_in == 0
% % %         
% % %     else 
% % %     S_Box_Bin=dec2bin(State_in(1,u),8);%S_Box((hex2dec(State_HexDec(1,1))+1),(hex2dec(State_HexDec(1,2)))+1),8);
% % %     S_Box_Bin_Invert1(1,8:-1:1)=S_Box_Bin(1,1:1:8);
% % %     S_Box_Bin_Invert2=reshape(S_Box_Bin_Invert1,8,1);
% % %     Subs(1:8,1)=0;
% % %     Substition=0;
% % %     for i=1:8
% % %         for j=1:8
% % %             if Mul(i,j) == 1
% % %                 Subs(i,1)=xor(Subs(i,1),bin2dec(S_Box_Bin_Invert2(j,1)));
% % %             end
% % %         end
% % %         %disp(Subs(i,1));
% % %         Subs(i,1)=xor(C(i,1),Subs(i,1));
% % %         if( Subs(i,1) == 1)
% % %             Substition=Substition+(2^(i-1));
% % %         end
% % %         %disp(Subs(i,1));
% % %     end
% % %     State_out(1,u)=Substition;
% % %     State_out(1,u)=Multiplicative_Inverse(State_out(1,u));
% % %     end
end