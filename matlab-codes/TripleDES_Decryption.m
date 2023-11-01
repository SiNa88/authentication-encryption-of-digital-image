function P=TripleDES_Decryption(C,RoundKey1,RoundKey2)

C1=DES_Decryption(C,RoundKey1);
C2=DES_Encryption(C1,RoundKey2);
P=DES_Decryption(C2,RoundKey1);