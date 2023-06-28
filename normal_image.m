function output = normal_image(input)
%NORMAL_IMAGE Summary of this function goes here
%   Detailed explanation goes here
    input(input<input(1,1)) = input(1,1);
    output = (input - min(min(input)))/(max(max(input)) - min(min(input)));
end

