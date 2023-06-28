function B = HT(A,zeta)
%HT Summary of this function goes here
%   Detailed explanation goes here
    B = (abs(A) > zeta).* (A);
end

