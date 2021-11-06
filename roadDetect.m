function road = roadDetect(img, intr, grad, boundaryMap, seg, inDeb)
    %ROADDETECT estimates the road area
    %   Detailed explanation goes here
    [nRow, nCol, nChan] = size(img);
    
    %----------------------------------
    %   
    %----------------------------------
    %p = generateProbMap(img,intr,grad, 0);
    %thresh = graythresh(p);
    %road = imbinarize(p, thresh);
    
    figure, imshow(seg), title('seg');
    
    
    boundaryMap = imresize(boundaryMap, [nRow, nCol]);
    road = logical(seg.*boundaryMap);
    
    
    figure, imshow(seg), title('seg');
    
    figure, imshow(boundaryMap), title('boundaryMap');
    
    figure, imshow(uint8(road)), title('final');
end

