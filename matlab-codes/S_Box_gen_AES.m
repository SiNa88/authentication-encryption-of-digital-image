function [S_Box Inv_S_Box]=S_Box_gen_AES
%Creating S_Box & S_Box_Inv

S_Box(1:16,1:16)=0;
Inv_S_Box(1:16,1:16)=0;

C=[1 1 0 0 0 1 1 0];    % 
C=reshape(C,8,1);
Mul(1:8,1:8)=0;
Mul(1,1:8)=[1 0 0 0 1 1 1 1];
for k=2:8
    Mul(k,:)=circshift(Mul(k-1,:),[0 1]);
end

for i=1:16
    for j=1:16
        if i==1 && j==1
            S_Box(i,j)=99;
            S=dec2hex(S_Box(i,j),2);
            I_J=0;
            Inv_S_Box(hex2dec(S(1,1)),hex2dec(S(1,2)))=I_J;
        else
            I_J=hex2dec(strcat(dec2hex(i-1),dec2hex(j-1)));
            S_B=Multiplicative_Inverse(I_J);
            S_Box_Bin=dec2bin(S_B,8);
            S_Box_Bin_Invert1(1,8:-1:1)=S_Box_Bin(1,1:1:8);
            S_Box_Bin_Invert2=reshape(S_Box_Bin_Invert1,8,1);
            Subs(1:8,1)=0;
            Substition=0;
            for k=1:8
                for h=1:8
                    if Mul(k,h) == 1
                        Subs(k,1)=xor(Subs(k,1),bin2dec(S_Box_Bin_Invert2(h,1)));
                    end
                end
                Subs(k,1)=xor(C(k,1),Subs(k,1));
                if( Subs(k,1) == 1)
                    Substition=Substition+(2^(k-1));
                end
            end
            S_Box(i,j)=Substition;
            S=dec2hex(S_Box(i,j),2);
            Inv_S_Box(hex2dec(S(1,1))+1,hex2dec(S(1,2))+1)=I_J; % producing Inverse S_Box
        end
    end
end