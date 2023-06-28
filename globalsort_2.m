function D_new = globalsort_2(D,U,k)
%GLOBALSORT Summary of this function goes here
%   Detailed explanation goes here
    D_new = zeros(size(D));
    D_temp = D;
    [n,p] = size(D);
    idx_set = zeros(1,k);
    sign_diag = zeros(1,k);
    for i = 1:k
        [~,idx]=maxk(abs(U(:,i)'*D_temp),1);
        sign_diag(i) = sign(U(:,i)'*D(:,idx));
        idx_set(i) = idx;
        D_temp(:,idx) = zeros(n,1);
    end
    
    
    D_new(:,1:k) = D(:,idx_set)*diag(sign_diag);
    if length(setdiff(1:p,idx_set)) == p-k
        D_new(:,k+1:end) = D(:,setdiff(1:p,idx_set));
    end
end

