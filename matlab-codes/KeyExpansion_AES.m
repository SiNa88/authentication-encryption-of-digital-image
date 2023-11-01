function w=KeyExpansion_AES(key,S_Box)

% % % NB=4;
% % % 
% % % if  NK==4
% % %     NR=10; % Number OF Rounds
% % % elseif  NK==6
% % %     NR=12; % Number OF Rounds
% % % elseif  NK==8
% % %     NR=14; % Number OF Rounds
% % % end

%Copy the first 16 cells of master key row_wise inTo the first four rows
%of the expanded key

w(1:44,1:4)=0;
w(1:4,:)=(reshape(key,4,4))';

for i = 5 : 44
    temp=w( i-1 , : ) ;
    if  mod(i,4)== 1     
        % With SUB-Table the first row is substituted Then with The R-Col 
        % is XORed
        temp = bitxor(Sub_Word(Rotate_Word(temp),S_Box) , R_Con((i-1)/4));
    end    
    w(i ,: ) = bitxor( w( (i-4) , : ) , temp);
end
% % % % %     elseif  NK>6 &&  mod(i,NK) == 4
% % % % %         temp=Sub_Word(temp);