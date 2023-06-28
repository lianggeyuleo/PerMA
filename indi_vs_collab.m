% Intialize the parameter
N = 10;
n = 6;
k = n;
theta = 0.3;
k_g = 3;
k_l = k - k_g; 
p = 200;
C = 0.3;
rng(2)
[D_gt,R] = qr(randn(n));
X_gt_list = zeros(k,p,N);
D_gt_list = zeros(n,k,N);
Y_list = zeros(n,p,N);
for i = 1:N
    Xb = randsrc(k,p,[1,0;theta,1-theta]);
    Xg = randn(k,p);
    X_gt_list(:,:,i) = liftlower(Xb .* Xg, C);

    [D2,R2] = qr(randn(k_l));
    D_gt_list(:,1:k_g,i) = D_gt(:,1:k_g);
    D_gt_list(:,k_g+1:end,i) = D_gt(:,k_g+1:end) * D2;

    Y_list(:,:,i) = D_gt_list(:,:,i) * X_gt_list(:,:,i);
end

T = 500;

X_list = zeros(k,p,N);


zeta = 0.99;


T0 = 200;
zeta = 2*C;
supp_rate = 0.8;

% Following precedure provides an initialization for both individual DL and
% perDL.

D_list_init = zeros(n,k,N);

% D_list_init = D_list_init_record;
for i = 1:N
    [D_list_init(:,:,i),~,~] = initialize(Y_list(:,:,i),zeta,T0,theta,supp_rate);
    D_list_init(:,:,i) = atom_flip(D_list_init(:,:,i));
end


D_list_indi = D_list_init;
D_list_collab = D_list_init;
D_list_init_record = D_list_init;
% Local DL: each clients run DL separately without collaboration.

Error_log = zeros(N+1,T);

for i = 1:N
    for t = 1:T
        X_list(:,:,i) = HT(D_list_indi(:,:,i)' * Y_list(:,:,i), 0.6*(zeta^t)+C/2);
        D_list_indi(:,:,i) = polardecomp(Y_list(:,:,i) * X_list(:,:,i)');
        D_g_local = globalsort(D_list_indi(:,:,i),D_gt(:,1:k_g),k_g);
        err = assignmentsolver(D_gt(:,1:k_g),D_g_local)-D_gt(:,1:k_g);
        Error_log(i,t) = max(vecnorm(err));
    end
end

% Following procedure provides an initialization for global dictionary with
% exchange of information between clients.

s = N*k +1;
t = N*k +2;

G = digraph(s*ones(1,k),1:k);
G.Edges.Weight = zeros(1,k)';
s_list = zeros(1,(N-1)*k^2+k);
t_list = zeros(1,(N-1)*k^2+k);
w_list = zeros(1,(N-1)*k^2+k);
itr = 1;
for i = 2:N
    for j = 1:k
        for h = 1:k
            s_list(itr) = (i-2)*k+h;
            t_list(itr) = (i-1)*k+j;
            w_list(itr) = min(norm(D_list_init(:,h,i-1)-D_list_init(:,j,i)),norm(D_list_init(:,h,i-1)+D_list_init(:,j,i)));
            itr = itr + 1;
        end
    end
%     disp(['Layer ',num2str(i-1),' is finished.'])
end
for h = 1:k
    s_list(itr) = (N-1)*k+h;
    t_list(itr) = t;
    w_list(itr) = 0;
    itr = itr + 1;
end 
G=addedge(G,s_list,t_list,w_list);


D_g_init = zeros(n,k_g);
for i = 1:k_g
    P = shortestpath(G,s,t);
    G = rmpath(G,P);
    l = length(P);
    std_atom = D_list_init(:,mod(P(2)+k-1,k)+1,ceil(P(2)/k));
    for j = 2:l-1
        D_g_init(:,i) = D_g_init(:,i) + D_list_init(:,mod(P(j)+k-1,k)+1,ceil(P(j)/k))*sign(std_atom'*D_list_init(:,mod(P(j)+k-1,k)+1,ceil(P(j)/k)));
    end
end

D_g_init = polardecomp(D_g_init);

for i = 1:N
    D_list_collab(:,:,i) = globalsort(D_list_collab(:,:,i),D_g_init,k_g);
    D_list_collab(:,1:k_g,i) = D_g_init;
    D_list_collab(:,:,i) = polardecomp(D_list_collab(:,:,i));
end

%PerDL: clients run DL collaboratively.

D_g = D_g_init;

for t = 1:T 
    for i = 1:N 
        X_list(:,:,i) = HT(D_list_collab(:,:,i)' * Y_list(:,:,i), 0.6*(zeta^t)+C/2);
        D_list_collab(:,:,i) = globalsort_2(polardecomp(Y_list(:,:,i) * X_list(:,:,i)'),D_g,k_g);
    end
    D_g = zeros(n,k_g);
    for i = 1:N 
        D_g = D_g + D_list_collab(:,1:k_g,i);
    end 
    D_g = polardecomp(D_g);
    for i = 1:N 
        D_list_collab(:,1:k_g,i) = D_g;
    end 
    err = assignmentsolver(D_gt(:,1:k_g),D_g)-D_gt(:,1:k_g);
    Error_log(N+1,t) = max(vecnorm(err));

end