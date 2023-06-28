function D = local_alter(Y, D, eta, T, thresh)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%     [~,p] = size(Y);
%     [~,k] = size(D);
%     X = zeros(k,p);
    for t = 1:T
%         for j = 1:p
%              X(:,j) = omp(Y(:,j), D, thresh);
%         end
        X = HT_2(D' * Y, thresh);
        D_old = D;
        D = D - 2*eta*(D*X - Y)*X';
        if norm(D_old - D)<1e-6
            disp(['Local refinement terminates earlier at t = ' num2str(t)]);
            break
        end
    end
end

