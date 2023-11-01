function P_IP=InitialPermutation(P_binry)
%   The order of 128-bit input changes according to below 
%   for Optimization & symmetry of the network
%   & doesn't help the strength of the algorithm!!!
P_IP=P_binry(1,[1 5 9 13 17 21 25 29 33 37 41 45 49 53 57 61 ,...
    65 69 73 77 81 85 89 93 97 101 105 109 113 117 121 125 ,...
    2 6 10 14 18 22 26 30 34 38 42 46 50 54 58 62 ,...
    66 70 74 78 82 86 90 94 98 102 106 110 114 118 122 126 ,...
    3 7 11 15 19 23 27 31 35 39 43 47 51 55 59 63 ,...
    67 71 75 79 83 87 91 95 99 103 107 111 115 119 123 127 ,...
    4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 ,...
    68 72 76 80 84 88 92 96 100 104 108 112 116 120 124 128]);