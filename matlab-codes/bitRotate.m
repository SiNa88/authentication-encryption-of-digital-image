function data = bitRotate(data,nBits)
%   Rotating the data by nBits rounds 
    dataBits=32;                                     % Number of bits in data
    nBits = rem(nBits,dataBits);                     % No need to rotate by dataBits bits or more
    if nBits == 0                                    % No bit rotation needed, just return
        return
    end
    shiftedData = bitshift(data,nBits,32);                    % Bit shift the data
    lostData = bitxor(data,bitshift(shiftedData,-nBits,32));  % Find the lost bits
    rotatedData = bitshift(lostData,nBits-sign(nBits)*dataBits,32);  % Rotate them
    data = bitxor(shiftedData,rotatedData);                        % Add the rotated bits to the shifted bits by XOR