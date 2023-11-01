function b_inv=Multiplicative_Inverse(a)
mod_pol=bin2dec('100011011');
for j = 1 : 255
    % "Test-wise" compute the polynomial multiplication 
    % of the input byte and the current "test byte"
    ab = 0;
    % Loop over every bit of the first factor ("a")
    % starting with the least significant bit.
    % This loop multiplies "a" and "b" modulo 2
    for i_bit = 1 : 8
    % If the current bit is set,
    % the second factor ("b") has to be multiplied
    % by the corresponding power of 2
        if bitget (a, i_bit)
            % The power-2-multiplication is carried out
            % by the corresponding left shift of the second factor ("b"),
            b_shift = bitshift (j, i_bit - 1);
            % and the modulo 2 (XOR) "addition" of the shifted factor
            ab = bitxor (ab, b_shift);
        end
    end
    for i_bit = 16 : -1 : 9
    % If the current bit is set,
    % "ab" (or the reduced "ab" respectively) has to be "divided"
    % by the modulo polynomial
        if bitget (ab, i_bit)
    
            % The "division" is carried out
            % by the corresponding left shift of the modulo polynomial,
            mod_pol_shift = bitshift (mod_pol, i_bit - 9);
        
            % and the "subtraction" of the shifted modulo polynomial.
            % Since both "addition" and "subtraction" are 
            % operations modulo 2 in this context,
            % both can be achieved via XOR
            ab = bitxor (ab, mod_pol_shift);
        
        end
        
    end

    % If the polynomial modulo multiplication leaves a remainder of "1"
    % we have found the inverse
    if ab == 1    
        % Declare (save and return) the current test byte as inverse,
        b_inv = j;
        % and abort the search
        break 
    end 
end