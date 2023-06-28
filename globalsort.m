function D_new = globalsort(D,U,k)
%GLOBALSORT Summary of this function goes here
%   Detailed explanation goes here
    [~,p] = size(D);
    [~,idx]=maxk(vecnorm(U'*D),k);
    D_new = zeros(size(D));
    D_new(:,1:k) = D(:,idx);
    D_new(:,k+1:end) = D(:,setdiff(1:p,idx));
end

