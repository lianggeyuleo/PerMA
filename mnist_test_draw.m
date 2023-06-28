% This script helps one reconstruct one image from the dictionary and the
% sparse coding we learned.
% Dic is the complete dictionary that we converted from the orthogonal
% dictionary D.
% number denotes the image number that one wants to reconstruct, it can
% be anything from 1 to 3000.
% k denotes the number of dictionary atoms that being used to construct the
% image.
% For example, when number = 17 and k = 5, then this script will find the
% top 5 largest entry in the sparse code corresponding to image 17, and
% reconstruct that image using that 5 coefficients and dictionary atoms. 



data = zeros(n,10000);
for i = 1:10000
    data(:,i) = reshape(x(:,:,i),[],1);
end

biased_idx = 1;

D_result_1 = D_list_indi(:,:,N+1);
D_result_2 = D_list_collab(:,:,N+1);


k = 5;



ImageMainArray = [];
for i = 1:20

    number = 9980+i;
    ImageArray = [];
    
    I0 = mat2gray(reshape(normal_image(data(:,number)),[28,28]));
    
    
    ImageArray = [ImageArray I0];
    
%     sparse_code = HT_2(D_result_1' * data(:,number), sparse_level);
    sparse_code = omp(data(:,number),D_result_1,k);
    [~,idx]=maxk(abs(sparse_code),k);
    X_reduced = D_result_1(:,idx)*sparse_code(idx,:);
    I1 = mat2gray(reshape(normal_image(X_reduced),[28,28]));
    
    ImageArray = [ImageArray I1];


    sparse_code = omp(data(:,number),D_result_2,k);
    [~,idx]=maxk(abs(sparse_code),k);
    X_reduced = D_result_2(:,idx)*sparse_code(idx,:);
    I2 = mat2gray(reshape(normal_image(X_reduced),[28,28]));
    
    ImageArray = [ImageArray I2];

    ImageMainArray = [ImageMainArray;ImageArray];
end




figure
montage(ImageMainArray);