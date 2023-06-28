function B = HT_2(A,k)
%HT Summary of this function goes here
%   Detailed explanation goes here
    [~,p] = size(A);
    B = zeros(size(A));
    for i = 1:p
        [~,I] = maxk(abs(A(:,i)),k);
        B(I,i) = A(I,i);
    end
end

