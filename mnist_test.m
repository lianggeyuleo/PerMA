  % Load MNIST data.

load('mnist.mat');
x=test.images;
y=test.labels;

p_total = 9000;
N = 9;
p_weak = 450;
p = 500;
n = 784;
k = 100;
k_g = 100;
k_l = k - k_g; 
T_init = 200;
T = 500;
sparse_level = 20;

Y_list = zeros(n,p,N);
D_list_init = zeros(n,k,N+1);


% Initialize Y and D matrices for each individual dataset.
Y_weak = zeros(n,p);
list = find(y==1);
for i = 1:p_weak
    Y_weak(:,i) =  reshape(x(:,:,list(i)),[],1);
end
for i = p_weak+1:p
    Y_weak(:,i) =  reshape(x(:,:,i),[],1);
end
D_list_init(:,:,N+1) = randn(n,k);

for i = 1:N
    list = find(y==mod(10,i+1));
    for j = 1:p_weak
        Y_list(:,j,i) = reshape(x(:,:,list(j)),[],1);
    end
    list = randsample(p_total,p-p_weak);
    for j = 1:p-p_weak
        Y_list(:,p_weak+j,i) = reshape(x(:,:,list(j)),[],1);
    end
    D_list_init(:,:,i) = randn(n,k);
end


disp('Data loading finished.')

% Initialization
for i = 1:N
    for t = 1:T_init
        X = HT_2(D_list_init(:,:,i)' * Y_list(:,:,i), sparse_level);
        D_list_init(:,:,i) = polardecomp(Y_list(:,:,i) * X');
        
    end
end


D_list_indi = D_list_init;
D_list_collab = D_list_init;
X_list_indi = zeros(k,p,N);
X_list_collab = zeros(k,p,N);

% Local DL on MNIST
tic
for t = 1:T
    X = HT_2(D_list_indi(:,:,N+1)' * Y_weak, sparse_level);
    D_list_indi(:,:,N+1) = polardecomp(Y_weak * X');
end
disp('Local DL finished.')
toc



% PerDL on MNIST
tic
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
    P = shortestpath(G,s,t,'Method','acyclic');
    G = rmpath(G,P);
    l = length(P);
    std_atom = D_list_init(:,mod(P(2)+k-1,k)+1,ceil(P(2)/k));
    for j = 2:l-1
        D_g_init(:,i) = D_g_init(:,i) + D_list_init(:,mod(P(j)+k-1,k)+1,ceil(P(j)/k))*sign(std_atom'*D_list_init(:,mod(P(j)+k-1,k)+1,ceil(P(j)/k)));
    end
end

D_g_init = D_g_init/N;

for i = 1:N
    D_list_collab(:,:,i) = globalsort(D_list_collab(:,:,i),D_g_init,k_g);
    D_list_collab(:,1:k_g,i) = D_g_init;
end

disp('Initialization for PerDL finished.')
toc

%PerDL: clients run DL collaboratively.

D_g = D_g_init;
tic
for t = 1:T 
    for i = 1:N 
        X = HT_2(D_list_collab(:,:,i)' * Y_list(:,:,i), sparse_level);
        D_list_collab(:,:,i) = globalsort_2(polardecomp(Y_list(:,:,i) * X'),D_g,k_g);
    end
    X = HT_2(D_list_collab(:,:,N+1)' * Y_weak, sparse_level);
    D_list_collab(:,:,N+1) = globalsort_2(polardecomp(Y_weak * X'),D_g,k_g);
    D_g = zeros(n,k_g);
    for i = 1:N+1
        D_g = D_g + D_list_collab(:,1:k_g,i);
    end 
    D_g = polardecomp(D_g);
    for i = 1:N+1 
        D_list_collab(:,1:k_g,i) = D_g;
    end 
%     disp(['Iteration ',num2str(t),' finished.'])
end
disp('PerDL finished.')
toc
