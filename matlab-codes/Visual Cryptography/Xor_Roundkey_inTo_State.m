function State_out=Xor_Roundkey_inTo_State(State,RoundKey,Counter)
% %
round_key = (RoundKey(((Counter*4)+1):((Counter*4)+4), :))';
State_out =  bitxor(State,round_key);