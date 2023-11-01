function p = psnr(x,y)

% psnr - compute the Peak Signal to Noise Ratio
%
%   p = psnr(x,y);
disp('The Mean Square Error between the Original Image & Encrypted Image :');
mse =MSE2(x,y);
disp(mse);
p = 10*log10( double((255^2)/mse) );