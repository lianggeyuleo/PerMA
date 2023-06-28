function A = liftlower(A,C)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    [a,b] = size(A);
    for i = 1:a
        for j = 1:b
            if abs(A(i,j))<C
                A(i,j) = sign(A(i,j)) * C;
            end
        end
    end
end

