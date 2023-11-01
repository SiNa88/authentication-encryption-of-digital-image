function n = ntz (x)
%   % number of trailing zeros (ntz), which counts the number of zero bits
%   % following the least significant one bit
    n = 0;
    if x == 0 
        n = 8;
    elseif bitand(x,hex2dec('7f')) == 0
        n = n + 7;
    elseif bitand(x,hex2dec('3f')) == 0  
        n = n + 6;
    elseif bitand(x,hex2dec('1f')) == 0
        n = n + 5;
    elseif bitand(x,hex2dec('0f')) == 0
        n = n + 4;
    elseif bitand(x,hex2dec('07')) == 0
        n = n + 3;
    elseif bitand(x,hex2dec('03')) == 0
        n = n + 2;
    elseif bitand(x,hex2dec('01')) == 0
        n = n + 1;
    end