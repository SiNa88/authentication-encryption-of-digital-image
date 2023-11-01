function RoundKey=KeyExpansion_Serpent(key,S_Box)

% 33 Secondary Keys producing from the Master Key
Key_binry=reshape(reshape(dec2bin(reshape( reshape(key,4,4)', 1, 16) ,8) ,16,8)' ,1,128);   % Converting Key to 128-bit Binary
Ta=((((sqrt(5))+1)/2)*(2^32)); % golden fraction

%   For expanding the MAsterKey to 256 Bits, '000...0001' prefix to Key
zrs(1:127)='0';
Extension=strcat(zrs,'1');      
Extended_Master_Key=strcat(Extension,Key_binry);    % Extending the MasterKey to 256-Bits

vector(1:8)=32;
W=mat2cell(Extended_Master_Key,1,vector);   % Breaking the Key To 32-bit Blocks
%   converting 32-bit Cells to binary
W{1}=bin2dec(W{1}); W{2}=bin2dec(W{2}); W{3}=bin2dec(W{3}); W{4}=bin2dec(W{4});
W{5}=bin2dec(W{5}); W{6}=bin2dec(W{6}); W{7}=bin2dec(W{7}); W{8}=bin2dec(W{8});
warning off;
k=1;
for i=9:140
    %   W(i) := (W(i-8) XOR W(i-5) XOR W(i-3) XOR W(i-1) XOR Ta XOR i)...
    %   <<< 11
    %   Ta is Double & should be converted to Integer
    W{i}=bitxor(bitxor(bitxor(bitxor(W{i-8},W{i-5}),W{i-3}),W{i-1}),floor(Ta));
    Word{k}=bitRotate(bitxor(W{i},k-1),11);
    W{i}=Word{k};
    Word{k}=dec2bin(Word{k},32);
    k=k+1;
end
vector2(1:32)=4;
j=0;    %   the last value in j will be 33
%   this while-loop will be executed just 5 times
while 1
    %   The Sequence of using S_Boxs is :  S_Box(4,:), S_Box(3,:),
    %   S_Box(2,:), S_Box(1,:), S_Box(8,:), S_Box(7,:), S_Box(6,:), S_Box(5,:)
    %   Then Concating every four 32-bit cell in a 128-bit single matrix
    %   & then breaking that matrix to thirty two 4-bit cells in order 
    %   To substitute values in one of eight S_Boxes for every four-bit cell
    WW=mat2cell(cell2mat(Word(4j+1:4j+4)),1,vector2);
    for s=1:32
        komakii=S_Box( 4 , bin2dec( WW{s} )+1 );    %S_Box(4,:)
        key_cell{s}=dec2bin(komakii,4);
    end
    %   Producing one of thirty three 128-bit RoundKeys
    j=j+1;RoundKey{j}= reshape(bin2dec(reshape(cell2mat(key_cell),8,16)'),4,4)';
    
    if j == 33  %   we just want to produce 33 RoundKeys
        break;
    end
    WW=mat2cell(cell2mat(Word(4j+1:4j+4)),1,vector2);
    for s=1:32
        komakii=S_Box( 3 , bin2dec( WW{s} )+1 );  %   S_Box(3,:)
        key_cell{s}=dec2bin(komakii,4);
    end
    j=j+1;RoundKey{j}= reshape(bin2dec(reshape(cell2mat(key_cell),8,16)'),4,4)';
    
    
    WW=mat2cell(cell2mat(Word(4j+1:4j+4)),1,vector2);
    for s=1:32
        komakii=S_Box( 2 , bin2dec( WW{s} )+1 );  %   S_Box(2,:)
        key_cell{s}=dec2bin(komakii,4);
    end
    j=j+1;RoundKey{j}= reshape(bin2dec(reshape(cell2mat(key_cell),8,16)'),4,4)';
    
    WW=mat2cell(cell2mat(Word(4j+1:4j+4)),1,vector2);
    for s=1:32
        komakii=S_Box( 1 , bin2dec( WW{s} )+1 );  %   S_Box(1,:)
        key_cell{s}=dec2bin(komakii,4);
    end
    j=j+1;RoundKey{j}= reshape(bin2dec(reshape(cell2mat(key_cell),8,16)'),4,4)';
    
    WW=mat2cell(cell2mat(Word(4j+1:4j+4)),1,vector2);
    for s=1:32
        komakii=S_Box( 8 , bin2dec( WW{s} )+1 );  %   S_Box(8,:)
        key_cell{s}=dec2bin(komakii,4);
    end
    j=j+1;RoundKey{j}= reshape(bin2dec(reshape(cell2mat(key_cell),8,16)'),4,4)';
    
    WW=mat2cell(cell2mat(Word(4j+1:4j+4)),1,vector2);
    for s=1:32
        komakii=S_Box( 7 , bin2dec( WW{s} )+1 );  %   S_Box(7,:)
        key_cell{s}=dec2bin(komakii,4);
    end
    j=j+1;RoundKey{j}= reshape(bin2dec(reshape(cell2mat(key_cell),8,16)'),4,4)';
    
    WW=mat2cell(cell2mat(Word(4j+1:4j+4)),1,vector2);
    for s=1:32
        komakii=S_Box( 6 , bin2dec( WW{s} )+1 );  %   S_Box(6,:)
        key_cell{s}=dec2bin(komakii,4);
    end
    j=j+1;RoundKey{j}= reshape(bin2dec(reshape(cell2mat(key_cell),8,16)'),4,4)';
    
    WW=mat2cell(cell2mat(Word(4j+1:4j+4)),1,vector2);
    for s=1:32
        komakii=S_Box( 5 , bin2dec( WW{s} )+1 );  %   S_Box(5,:)
        key_cell{s}=dec2bin(komakii,4);
    end
    j=j+1;RoundKey{j}= reshape(bin2dec(reshape(cell2mat(key_cell),8,16)'),4,4)';
end