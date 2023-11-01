function share12=inversseVisuCrypto(share1,share2)

share12=bitxor(share1, share2);
share12 = ~share12;
share12=imresize(share12,size(share12).*[1 .5]);
% disp('Share Generation Completed.');
% figure;imshow(share12);title('Overlapping Share 1 & 2');