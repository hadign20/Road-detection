function roadMask2 = rgbAngular(rgbImage, mask)
    
    [nRow, nCol, nChannel] = size(rgbImage);

    %-- split channels
    R = rgbImage(:, :, 1);
    G = rgbImage(:, :, 2);
    B = rgbImage(:, :, 3);
    
    % Get medians
    medR = median(R(mask));
    medG = median(G(mask));
    medB = median(B(mask));
    
    %median of the road region
    med = [medR, medG, medB];
    
    thetas = zeros(nRow, nCol);
    for i=1:nCol
        for j=1:nRow
            theta = colorangle([rgbImage(j,i,1),rgbImage(j,i,2),rgbImage(j,i,3)], med);
            thetas(j,i) = theta;
        end
    end
    
    figure, imshow(thetas,[]);
    
    %polarhistogram(thetas);
    
    roadMask2 = rgbImage;
end

