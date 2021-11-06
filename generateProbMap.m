function [probMap] = generateProbMap(inImg,intr,grad,inDeb)
%GENERATEPROBMAPS Summary of this function goes here
%   Detailed explanation goes here
    
    %-- histogram equalization of intrinsic image
    intrEq = histeq(real(intr));
    %figure, imshow(intrEq);
    intr = imgaussfilt(intr, 3);

    %-- load initial road sample mask
    maskImg = imread('data/mask.png');
    mask = imbinarize(maskImg);
    meanMask = mean2(intr(mask));
    stdMask = std2(intr(mask));

    %-- gray difference of intrinsic image
    Gdiff = histeq(abs(intr - meanMask));
    if inDeb==1, figure('NumberTitle', 'off', 'Name', 'Gdiff'), imshow(Gdiff,[]); title('Gdiff'); end

    %-- hue difference of intrinsic image
    re = 255 * real(intr);
    re = uint8(255 * mat2gray(abs(intr)));
    intrRgb = uint8(gray2rgb(re,inImg));
    %figure, imshow(intrRgb);
    intrHsv = rgb2hsv(intrRgb);
    [h_intr, s_intr, v_intr] = imsplit(intrHsv);
    %figure, imshow(h_intr,[]);

    meanHmask = mean2(h_intr(mask));
    Hdiff = abs(h_intr - meanHmask);
    if inDeb==1, figure('NumberTitle', 'off', 'Name', 'Hdiff'), imshow(Hdiff,[]); title('Hdiff'); end
    
    %-- gray prob map
%     [rows cols chans] = size(intr);
%     Pg = double(zeros(rows, cols));
%     Pg(Gdiff < stdMask) = 1;
%     Pg((Gdiff >= stdMask) & (Gdiff < 2*stdMask)) = 1.5 - (0.5 * (Gdiff./stdMask));
%     Pg((Gdiff >= 2*stdMask) & (Gdiff < 3*stdMask)) = 1.1 - (0.3 * (Gdiff./stdMask));
    Pg = (1 - Gdiff)./ max(Gdiff, [] , 'all');
    Pg = imadjust(Pg,stretchlim(Pg),[]); %-- contrast stretching
    if inDeb==1, figure('NumberTitle', 'off', 'Name', 'Pg'), imshow(Pg), title('grayscale difference probability map'); end
    
    %-- hue prob map
    %Ph = (1 - Hdiff)./ max(Hdiff, [] ,'all');
    Ph = (1 - Hdiff).^2;
    Ph = imadjust(Ph,stretchlim(Ph),[]); %-- contrast stretching
    if inDeb==1, figure('NumberTitle', 'off', 'Name', 'Ph'), imshow(Ph), title('Ph'); end
    
    %-- grad prob map
    Pe = (1 - grad).^2;
    Pe = imadjust(Pe,stretchlim(Pe),[]); %-- contrast stretching
    if inDeb==1, figure('NumberTitle', 'off', 'Name', 'Pe'), imshow(Pe); title('Pe'); end
    
    %----------------------
    %-- combine prob maps
    %----------------------
    merged = cat(10, Pg,Pg,Pg,Pg,Pg, Ph,Ph,Ph, Pe,Pe);
    Pmed = median(merged, 10);
    
    if inDeb==1, figure('NumberTitle', 'off', 'Name', 'Pmed'), imshow(Pmed), title('Pmed'); end

    probMap = Pmed;
end

