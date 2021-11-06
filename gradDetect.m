function [gradMap] = gradient(inImg, intr, inDeb)
%GRADIENT Summary of this function goes here
%   Detailed explanation goes here
    
    inImgGray = rgb2gray(inImg);
    inImgGrayB = imgaussfilt(inImgGray, 2);
    intrB = imgaussfilt(real(intr), 2);
    
    im_edge = edge(inImgGrayB, 'Canny');
    intr_edge = edge(intrB, 'Canny');
    if inDeb == 1, figure, imshowpair(im_edge, intr_edge, 'montage'); end
    [Gmag, Gdir] = imgradient(intrB,'sobel');
    
    if inDeb == 1
        [Gmag, Gdir] = imgradient(inImgGrayB,'sobel');
        figure
        imshowpair(Gmag, Gdir, 'montage');
        figure
        [Gx,Gy] = imgradientxy(inImgGrayB);
        imshowpair(Gx,Gy,'montage');

        [Gmag, Gdir] = imgradient(intrB,'sobel');
        figure
        imshowpair(Gmag, Gdir, 'montage');
        figure
        [Gx,Gy] = imgradientxy(intrB);
        imshowpair(Gx,Gy,'montage');
    end
    
%     figure
%     imshow(Gmag);
%     maskImg = imread('data/mask.png');
%     mask = imbinarize(maskImg);
%     [rows,columns] = find(mask);
%     b = imbinarize(uint8(255*mat2gray(abs(intr))));
%     %bw = imfill(Gmag, [rows(:) columns(:)]);
%     bw = imfill(Gmag, [141 213], 4);
%     
%     figure
%     imshow(bw);
    
    gradMap = double(Gmag);

end

