function M_S_E=MSE2(Im,Im_Encrypted)
[m n]=size(Im);
% Im_Encrypted2(m,n)=Im_Encrypted(m,n);
% M_S_E = mean( mean( (double(Im(:))-Im_Encrypted2(:)).^2 ) );
s=0;
for j=1:(m*n)
    s=s+((double((Im_Encrypted(j)))-double(Im(j))).^2 );
end
M_S_E=s/(m*n);