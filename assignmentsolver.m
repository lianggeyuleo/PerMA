function C = assignmentsolver(A,B)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    [~,k] = size(A);
    Cost = zeros(k,k);
    Sign = zeros(k,k);
    for i = 1:k
        for j = 1:k
             if norm(A(:,i)-B(:,j)) < norm(A(:,i)+B(:,j))

                 Cost(i,j) = norm(A(:,i)-B(:,j));
                 Sign(i,j) = 1;

             else

                 Cost(i,j) = norm(A(:,i)+B(:,j));
                 Sign(i,j) = -1;

             end
        end
    end
    M = matchpairs(Cost, 1e10);
    C = zeros(size(A));
    for i = 1:k
        C(:,M(i,1)) = B(:,M(i,2)) * Sign(M(i,1),M(i,2));
    end


end

