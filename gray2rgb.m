function R=gray2rgb(imt,ims)

[tx, ty, tz] = size(imt); % get size of target image
[~, ~, sz] = size(ims); % get 3rd dim of source
if tz ~= 1 % convert the destination image to grayscale if not already
    imt = rgb2gray(imt);
end
if sz ~= 3 % check to see that the source image is RGB
    disp ('img2 must be a color image (not indexed)');
else
    imt(:, :, 2) = imt(:, :, 1); % add green channel to grayscale img
    imt(:, :, 3) = imt(:, :, 1); % add blue channel to grayscale img
   
% Converting to ycbcr color space
    % ycbcr, y: luminance, cb: blue difference chroma, cr: red difference chroma
    % s - source, t - target
    nspace1 = rgb2ycbcr(ims); % convert source img to ycbcr color space
    nspace2 = rgb2ycbcr(imt); % convert target img to ycbcr color space
    
    % Get unique values of the luminance
    [ms, ics, ~] = unique(double(nspace1(:, :, 1))); % luminance of src img
    mt = unique(double(nspace2(:, :, 1))); % luminance of target img
    % Establish values for the cb and cr content from the source
    % image
    cbs = nspace1(:, :, 2);
    cbs = cbs(ics);
    crs = nspace1(:, :, 3);
    crs = crs(ics);
    
    % get max and min luminance of src and target
    m1 =max(ms);
    m2 = min(ms);
    m3 = max(mt);
    m4 = min(mt);
    d1 = m1 - m2; % get difference between max and min luminance
    d2 = m3 - m4;
    % Normalization 
    dx1 = ms;
    dx2 = mt;
    dx1 = (dx1 * 255) / (255 - d1); % normalize source
    dx2 = (dx2 * 255) / (255 - d2); % normalize target
    [mx, ~] = size(dx2);
    % luminance and normalization of target image
    nimage_norm = double(nspace2(:, :, 1));
    nimage_norm =(nimage_norm * 255) / (255 - d2);
    
    % Luminance Comparison
    nimage = nspace2;
    nimage_cb = nimage(:, :, 2);
    nimage_cr = nimage(:, :, 3);
    
    % reshape cb and cr channels to be column vector
    nimage_cb = reshape(nimage_cb, numel(nimage_cb), 1);
    nimage_cr = reshape(nimage_cr, numel(nimage_cr), 1);
    
    % CHANGE: Loop through dx2 luminance values and find location of 
    % corresponding luminance values in nimage_norm. Assign cb and cr 
    % values to nimage's cb and cr channels for matching values
    
    for i = 1:mx
        iy = dx2(i);
        tmp = abs(dx1 - iy); % calculate absolute difference between 
        % specific normalized target luminance value and normalized 
        % source luminance values
        ck = min(tmp);
        % finds min value of absolute diff. between specific 
        % normalized target luminance value and normalized source
        % luminance values
        r = find(tmp == ck); % finds row and column where tmp = ck
        cb = cbs(r, 1); % establish cb value
        cr = crs(r, 1); % establish cr value
        mtch = find(nimage_norm == iy); % find linear indicies of matching
        % luminance values
        nimage_cb(mtch) = cb(1); % set cb values based on matching lum vals
        nimage_cr(mtch) = cr(1); % set cr values based on matching lum vals
    end
    
    % reshape cb and cr channels to original image dimensions
    nimage_cb = reshape(nimage_cb, tx, ty);
    nimage_cr = reshape(nimage_cr, tx, ty);
    % assign cb and cr channelse of output image
    nimage(:, :, 2) = nimage_cb;
    nimage(:, :, 3) = nimage_cr;

    rslt = ycbcr2rgb(nimage);
    R = uint8(rslt);
end