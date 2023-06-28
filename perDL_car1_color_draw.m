index = 29;
global_y = U_list(:,:,index)*X_list(1:k_g,:,index);
    global_recon = zeros(im_row,im_col,3);
    global_recon(:,:,1) = patch_single(global_y(1:(im_row*im_col)/(p_row*p_col),:).',im_row,im_col,p_row,p_col,1);
    global_recon(:,:,2) = patch_single(global_y((im_row*im_col)/(p_row*p_col)+1:2*(im_row*im_col)/(p_row*p_col),:).',im_row,im_col,p_row,p_col,1);
    global_recon(:,:,3) = patch_single(global_y(2*(im_row*im_col)/(p_row*p_col)+1:end,:).',im_row,im_col,p_row,p_col,1);

    local_y = V_list(:,:,index)*X_list(k_g+1:end,:,index);
    local_recon = zeros(im_row,im_col,3);
    local_recon(:,:,1) = patch_single(local_y(1:(im_row*im_col)/(p_row*p_col),:).',im_row,im_col,p_row,p_col,1);
    local_recon(:,:,2) = patch_single(local_y((im_row*im_col)/(p_row*p_col)+1:2*(im_row*im_col)/(p_row*p_col),:).',im_row,im_col,p_row,p_col,1);
    local_recon(:,:,3) = patch_single(local_y(2*(im_row*im_col)/(p_row*p_col)+1:end,:).',im_row,im_col,p_row,p_col,1);


%index selection(): 16 29 10

  imshow(uint8(255*mat2gray(global_recon)));

%    imshow(uint8(255*mat2gray(local_recon)));

%  imshow(uint8(Data_list(:,:,:,index)));
