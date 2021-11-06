function [ illum_invar ] = shadowFeature(image, bias, inv)
rgb = im2double(image);

R = im2double(rgb(:,:,1));
G = im2double(rgb(:,:,2));
B = im2double(rgb(:,:,3));

hsv = im2double(rgb2hsv(image));
H = hsv(:,:,1);
S = hsv(:,:,2);
V = hsv(:,:,3);

% illum_invar =  2 - (S+bias)./(B+eps);
% figure, imshow(illum_invar);
% 
% illum_invar =  2 - (G+bias)./(B+eps);
% figure, imshow(illum_invar);
% 
illum_invar =  2 - (V )./(B+eps);
% figure, imshow(illum_invar);


illum_invar(illum_invar<0) = 0;
illum_invar(illum_invar>1) = 1;

if nargin>2 && inv
	illum_invar = 1-illum_invar;
end