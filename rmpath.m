function G = rmpath(G,P)
%RMPATH Summary of this function goes here
%   Detailed explanation goes here
    [~,len] = size(P);
    for i = 1:len-1
        G = rmedge(G,P(i),P(i+1));
    end
end

