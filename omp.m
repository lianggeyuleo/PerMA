function code = omp(data,Dic,sparse_level)
%OMP Summary of this function goes here
%   Detailed explanation goes here
    [~,k] = size(Dic);
    y_temp = data;
    supp = zeros(1,sparse_level);
    for j = 1:sparse_level
        [~,idx] = max(abs(Dic' * y_temp));
        supp(1,j) = idx;
        x_temp = pinv(Dic(:,supp(1,1:j)))*data;
        y_temp = data - Dic(:,supp(1,1:j)) * x_temp;
%         if norm(y_temp)<1e-5
%             break
%         end
    end  
    code = zeros(k,1);
    code(supp) = x_temp;
end

