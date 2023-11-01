function Auth=Hash(A,key,reply)
%    The 128-bit string one gets by processing the associated data A

%    Input:
%      key, string of KEYLEN bits                     // Key
%      Im, string of any length                       // Associated data
%    Output:
%      Sum, string of 128 bits                       // Hash result

if reply == 'A' || reply=='a'
    [S_Box   Inv_S_Box   RoundKey]=AES_Initializing(key);
    fun1=@AES_Encryption;
elseif reply == 'S' || reply=='s'
    [S_Box  Inv_S_Box    RoundKey]=Serpent_Initializing(key);
    fun1=@Serpent_Encryption;
end
    A=resize(A);
    %
    % Consider A as a sequence of 128-bit blocks
    %
    SizeOfOriginalPic=size(A);
    Rows=SizeOfOriginalPic(1,1);    Rows=Rows/4;
    Cols=SizeOfOriginalPic(1,2);    Cols=Cols/4;
    Vector1(1:Rows)=4;
    Vector2(1:Cols)=4;
    A=double(A);    %    The Image should be converted to double
    A=mat2cell(A,Vector1,Vector2);
     
    %
    % Process any whole blocks
    %
    Sum = zeros(4,4);
    Offset = zeros(4,4);   %   the initial value is  Init = 0
    
    %
    % Key-dependent variables
    %
    L=Doubl(fun1(zeros(4,4),RoundKey,S_Box));
    L_Key_dependent{1,1}=Doubl(L);
    
    for i=1:Rows
        for j=1:Cols
            if j~=1 % i~=1///i==1
                L_Key_dependent{i,j}=Doubl(L_Key_dependent{i,j-1});
            elseif i~=1 && j==1
                L_Key_dependent{i,j}=Doubl(L_Key_dependent{i-1,Cols});
            end
        end
    end
    for i=1:Rows
        for j=1:Cols
            Offset = bitxor(Offset, L_Key_dependent{ntz(i)+1,ntz(j)+1});
            Sum = bitxor(Sum,fun1(bitxor(A{i,j},Offset),RoundKey,S_Box));
%             if j~=1 % i~=1///i==1
%                 Offset = bitxor(Offset, L_Key_dependent{ntz(i)+1,ntz(j)+1});
%                 Sum = bitxor(Sum,fun1(bitxor(A{i,j} ,Offset),RoundKey,S_Box));
%             elseif i~=1 && j==1
%                 Offset = bitxor(Offset, L_Key_dependent{ntz(i)+1,ntz(j)+1});
%                 Sum = bitxor(Sum,fun1(bitxor(A{i,j} ,Offset),RoundKey,S_Box));
%             end
        end
    end
Auth=Sum;