function Output = patch_single(Input, row_num, col_num, p_row_num, p_col_num, dir_flag)
%patch_single Summary of this function goes here
%   dir_flag : 0 -> divide pictures into patches
%               1 -> Reverse
    
    if dir_flag == 0
        Output = reshape(Input, row_num, p_col_num, col_num/p_col_num);
        Output = permute(Output,[2 1 3]);
        Output = reshape(Output, p_col_num, p_row_num, (col_num * row_num)/ (p_col_num * p_row_num));
        Output = permute(Output,[2 1 3]);
        Output = reshape(Output, p_col_num * p_row_num, (col_num * row_num)/ (p_col_num * p_row_num));
    else
        Output = reshape(Input, p_row_num, p_col_num, (col_num * row_num)/ (p_col_num * p_row_num));
        Output = permute(Output,[2 1 3]);
        Output = reshape(Output, p_col_num, row_num, col_num/p_col_num);
        Output = permute(Output,[2 1 3]);
        Output = reshape(Output, row_num, col_num);
    end
end

