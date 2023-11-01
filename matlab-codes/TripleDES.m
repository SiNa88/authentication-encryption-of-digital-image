function out=TripleDES(P,RoundKey1,RoundKey2)
C=DES_Encryption(P,RoundKey1);
C2=DES_Decryption(C,RoundKey2);
out=DES_Encryption(C2,RoundKey1);