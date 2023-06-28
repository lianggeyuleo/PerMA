function A = atom_flip(A)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    [~,p] = size(A);
    for i = 1:p
        if A(1,i)<0
            A(:,i) = - A(:,i);
        end
    end
end

