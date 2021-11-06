function main(inDeb)

    global deb; 
    deb = 0; % debug flag (set to 1 to enable debugging)
    if nargin == 1, deb = inDeb; end


    ipath = 'data/in3/'; % input images path
    gpath = 'data/gt/'; % input ground truth path
    intrOpath = 'data/out/intr/'; % intrinsic images output path
    roadOpath = 'data/out/road/'; % detected roads output path
    boundaryOpath = 'data/out/boundary/'; % detected roads baoundary path
    if ~exist(intrOpath, 'dir'), mkdir(intrOpath); end
    if ~exist(roadOpath, 'dir'), mkdir(roadOpath); end
    if ~exist(boundaryOpath, 'dir'), mkdir(boundaryOpath); end
    
    imds = imageDatastore(ipath, 'FileExtensions', {'.jpeg', '.jpg', '.tif', '.png'}); 
    gtds = imageDatastore(gpath, 'FileExtensions', {'.jpeg', '.jpg', '.tif', '.png'});
    numImages = numel(imds.Files); % number of input images
    
    imNum = (1:numImages);
    FPR = [0];
    ACC = [0];
    F = [0];
    Time = [0];
    while hasdata(imds)
        [img, imgInfo] = read(imds);
        [filepath,imgName,ext] = fileparts(imgInfo.('Filename'));
        fprintf('process %s \n', imgName);
        tStart = tic;
        
        %-- calculate intrinsic image
        intr = intrinsic(im2double(img), deb);
        if deb == 0, imwrite(mat2gray(abs(intr)), [intrOpath, imgName,ext]); end
        
        %-- calculate gradient image
        %grad = gradDetect(img, abs(intr), deb);
        
        %-- road boundary detection\
        h = figure('NumberTitle', 'off', 'Name', imgName);
        %ResizedImg = imresize(img, [150, 200]);
        imshow(img);
        boundaryMap = boundaryDetect(img);
        %myGCF = getframe(gcf);
        %[X, Map] = frame2im(myGCF);
        %imwrite(X, [boundaryOpath, imgName, ext]);
        %close(h);
        %figure, imshow(boundaryMap);
      
        %-- region segmentation
        im2 = shadowFeature(img,0.0,0);
        
        maskImg = imread('data/mask.png');
        m = imbinarize(maskImg);
        I = imresize(im2,.5); 
        m = imresize(m,.5);  

        seg = segmentation(I, m, 700, deb); 
%         I2 = imfill(logical(I), [50 40],8);
%         figure, imshow(I2);
        %figure, imshow(seg);

        %-- initial road detection
        %roadMask1 = roadDetect(img, abs(intr), grad, boundaryMap, seg, deb);
        %roadMask1 = roadDetect(img, abs(intr), boundaryMap, seg2, deb);
        
        [nRow, nCol, nChan] = size(img);
        boundaryMap = imresize(boundaryMap, [nRow, nCol]);
        seg = imresize(seg, [nRow, nCol]);
        roadMask1 = logical(seg.*boundaryMap);
        
        %-- color difference
        %roadMask2 = rgbAngular(img, roadMask1);
        
        tEnd = toc(tStart);
        Time = [Time tEnd];
        
        if deb == 0
            roadRed = img;
            roadRed(roadMask1) = 255;
            imwrite(roadRed, [roadOpath, imgName, ext]);
        end
        
        %-- evaluation
        [gt, gtInfo] = read(gtds);
        [filepath,gtName,ext] = fileparts(gtInfo.('Filename'));
        if gtName == strcat(imgName,'_GT')
            [fpr, acc, fscore] = evaluateMetrics(logical(gt), roadMask1);
            FPR = [FPR fpr];
            ACC = [ACC acc];
            F = [F fscore];
        end
    end
    
    figure
    plot(imNum, FPR, 'r');
    hold on
    plot(imNum, ACC, 'b:');
    hold on
    plot(imNum, F, 'g-.');
    legend('FPR', 'ACC', 'F-Score');

end