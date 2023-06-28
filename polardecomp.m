function B = polardecomp(A)
%POLAR Summary of this function goes here
%   Detailed explanation goes here
    [U,~,V] = svd(A,"econ");
    B = U * V';
end

