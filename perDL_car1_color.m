folder_path = pwd;
folder_path = [folder_path,['/','car1','/']];
file_list = dir([folder_path '*.jpg']);

N = length(file_list);
im_row = 480;
im_col = 640;
p_row = 40;
p_col = 40;

n = 3*(im_row*im_col)/(p_row*p_col); % Pooling
p = p_row*p_col; 
k_g = 100;
% k_l = 300;
k_l = n - k_g;
k = k_g + k_l;
thresh = 50;
T = 15;
eta = 1e-10;

eta_local = eta; 
T_local = 100; 
thresh_local = thresh;

Data_list = zeros(im_row,im_col,3,N);
Y_list = zeros(n,p,N);
U_list = zeros(n,k_g,N);
V_list = zeros(n,k_l,N);
X_list = zeros(k,p,N);
D_list_init = zeros(n,k,N);

for i = 1:N
    file_name = file_list(i).name;
    file_path = [folder_path file_name];
    image_data = imread(file_path);
    I = double(image_data);
    Data_list(:,:,:,i) = I;
    Y_list(:,:,i) = [patch_single(I(:,:,1),im_row,im_col,p_row,p_col,0).';...
        patch_single(I(:,:,2),im_row,im_col,p_row,p_col,0).';...
        patch_single(I(:,:,3),im_row,im_col,p_row,p_col,0).'];
    [U_init,~,~] = svd(Y_list(:,:,i));
    D_list_init(:,:,i) = U_init(:,1:k);
end





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
    disp(['Layer ',num2str(i-1),' is finished.'])
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
    for j = 2:l-1
        D_g_init(:,i) = D_g_init(:,i) + D_list_init(:,mod(P(j)+k-1,k)+1,ceil(P(j)/k));
    end
end

D_g_init = D_g_init/N;


disp('Initialization for PerDL finished.')
toc



for i = 1:N
    U_list(:,:,i) = D_g_init(:,1:k_g);
    V_init = randn(n,k_l);
    V_list(:,:,i) = polardecomp(V_init - D_g_init(:,1:k_g)*D_g_init(:,1:k_g)'*V_init);
end


loss_list = zeros(1,T);

for t = 1:T
    U_g = zeros(n,k_g);
    loss = 0;
    for i = 1:N
        Uk = U_list(:,:,i);
        Vk = V_list(:,:,i);
        Wk = [Uk,Vk];
        X_list(:,:,i) = HT_2(Wk' * Y_list(:,:,i), thresh);
        loss = loss + norm( Wk*X_list(:,:,i) - Y_list(:,:,i),'fro')^2;

        Wk = Wk - 2*eta*(Wk*X_list(:,:,i) - Y_list(:,:,i))*X_list(:,:,i)';

        U_list(:,:,i) = Wk(:,1:k_g);
        V_list(:,:,i) = Wk(:,k_g+1:end);
        U_g = U_g + U_list(:,:,i);
    end
    loss_list(1,t) = loss;
    U_g = polardecomp(U_g);

    

    for i = 1:N
        U_list(:,:,i) = U_g;
        X_U = HT_2(U_g' * Y_list(:,:,i), thresh);
        Y_res = Y_list(:,:,i) - U_g*X_U;

        % Local Refinement
        V_list(:,:,i) = local_alter(Y_res, Vk, eta_local, T_local, thresh_local);
        
    end

    disp(['Iteration no.' num2str(t) ' finished.']);
    disp(['Current loss: ' num2str(loss)]);
end


plot(loss_list);