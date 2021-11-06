% r = [184,183,191];
% sh = [85,86,91];
% sky = [238,243,239];
% im = imread('K:\My Drive\image_processing\paper2\data\in\SR_003.jpg');
% A_lin = rgb2lin(im);
% illuminant = illumpca(A_lin);
% 
% 
% B_lin = chromadapt(A_lin,illuminant,'ColorSpace','linear-rgb');
% B = lin2rgb(B_lin);
% figure
% imshow(B,'InitialMagnification',25)
% title('White-Balanced Image using Principal Component Analysis');

im = imread('G:\My Drive\image_processing\paper2\data\in\SR_015.jpg');
img = 'G:\My Drive\image_processing\paper2\data\in\SR_017.jpg';

[fig, missL(n), missM(n), missR(n)]  = roadDetection(img, 'ours');
% img = ying2016(im,0.0,0);
% imwrite(img,'K:\My Drive\image_processing\paper2\data\im.png');

