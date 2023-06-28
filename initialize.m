function [D,X,i] = initialize(Y,zeta,T0,theta,supp_rate)
    th = zeta;
    [n,p] = size(Y);
    D = eye(n);
    for i = 1:T0

        th = th * 0.99;
        X = (abs(D' * Y) > th).* (D' * Y);
        [U1,Sig,U2] = svd(Y * X');
        D = U1 * U2';
        if sum(abs(X)>0,"all")>supp_rate*n*p*theta
            break
        end
        
    end

end

