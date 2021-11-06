function boundaryMap = boundaryDetect(RGB)

%% init params
    [nRow, nCol, nChannel] = size(RGB);
    rSplit = ceil(nRow/3);
    cSplit = ceil(nCol/2);

    thetaRange = 15:75;
    
    boundaryMap = ones(nRow, nCol);

    if nChannel ~= 3
        disp('Color image is needed for road boundary detection.');
        return;
    end
%% image preprocessing

    % Region of interest determination - lower 3/4
    ROI = RGB(rSplit:end,:,:);
    nRowRoi = size(ROI, 1);
    
    % Image gray value conversion - S2 feature extraction
    
    B = ROI(:,:,3);
    V = max(ROI,[],3);
    feature = double(V - B) ./ double(V + 1); % S2
        
    imwrite(feature, 'K:\My Drive\Sem5\image_processing\paper2\data\out\binary\feature.jpg');

    %% Image segmentation
    % Filter out lane markings and objects
    Filtered = medfilt2(feature, [1, 10]);
    S2_BW = im2bw(Filtered, graythresh(Filtered(Filtered>mean(Filtered(:)))));
    
    imwrite(S2_BW, 'K:\My Drive\Sem5\image_processing\paper2\data\out\binary\S2_BW.jpg');
  
    Boundaries = S2_BW; %S2_BW&(~LaneMarking);

%% Boundary points extraction

    Candidate = zeros(nRowRoi, nCol);
    BoundaryL = zeros(nRowRoi, cSplit);
    BoundaryR = zeros(nRowRoi, nCol - cSplit);

    % bottom-up scan
    for c = 1 : nCol % for each column
        r = find(Boundaries(:,c),1,'last');
        Candidate(r, c) = 1;
    end

    % middle-side scan
    for r = 1 : nRowRoi
        c1 = find(Candidate(r,1:cSplit),1,'last'); 
        c2 = find(Candidate(r,cSplit+1:end),1,'first');
        BoundaryL(r, c1) = 1;
        BoundaryR(r, c2) = 1;
    end
    
    imwrite(Candidate, 'K:\My Drive\Sem5\image_processing\paper2\data\out\binary\Candidate.jpg');

    imdump(3, feature, S2_BW, Boundaries, Candidate, BoundaryL, BoundaryR);

%% Road boundary model fitting
    houghL = figure;
    lineL = bwFitLine(BoundaryL, thetaRange);
    houghR = figure;
    lineR = bwFitLine(BoundaryR, -thetaRange);
    
    imdump(3,houghL,houghR);
    close(houghL,houghR);
    
    thetaRight = thetaRange(2);
    thetaLeft = -thetaRange(2);

    missL = isempty(lineL);
    if missL
       disp('Fail in left boundary line fitting.');
    else
       thetaRight = floor(lineL.theta - 20);
       thetaRight = max(thetaRight, thetaRange(1));
       lineL.move([0, rSplit]);
       hold on, lineL.plot('LineWidth',3,'Color','yellow');
    end

    missR = isempty(lineR);
    if missR
       disp('Fail in right boundary line fitting.');
    else
       thetaLeft = floor(lineR.theta + 20);
       thetaLeft = min(thetaLeft, -thetaRange(1));
       lineR.move([cSplit, rSplit]);
       hold on, lineR.plot('LineWidth',3,'Color','green');
    end

    thetaSet = thetaLeft:thetaRight;
    
    if ~isempty(lineL) && ~isempty(lineR)
        PointO = lineL.cross(lineR);
        PointL = [lineL.row(nRow), nRow];
        PointR = [lineR.row(nRow), nRow];
        
        rHorizon = max(1,floor(PointO(2)));
        cBoundaryL = lineL.row(rHorizon:nRow);
        cBoundaryR = lineR.row(rHorizon:nRow);
        
        % Plot results
        hold on;
        
        % lines
        lineH = LineObj([1, rHorizon], [nCol, rHorizon]);
        lineH.plot('LineWidth',3,'Color','red');
        % extend lines
        lineExL = LineObj(PointO, PointL);
        lineExL.plot('LineWidth',1,'Color','yellow');
        lineExR = LineObj(PointO, PointR);
        lineExR.plot('LineWidth',1,'Color','green');
        
        % points
        plot(PointO(1), PointO(2), 'ro', 'markersize', 10);
        plot(PointL(1), PointL(2), 'r*');
        plot(PointR(1), PointR(2), 'r*');
        
        %----------------------------------------------
        % boundary with left and right
%          for i=1:nCol	
%             for j=1:nRow	
%                 if lineSide([i,j],PointL, PointO) > 0	
%                     boundaryMap(j,i) = 0;	
%                 end	
%                 if lineSide([i,j],PointO, PointR) > 0	
%                     boundaryMap(j,i) = 0;	
%                 end	
%             end	
%         end	
%         boundaryMap = logical(boundaryMap);
        %----------------------------------------------
        % boundary with just horizon line
         for i=1:nCol	
            for j=1:nRow	
                if j < rHorizon	
                    boundaryMap(j,i) = 0;	
                end	
            end	
        end	
        boundaryMap = logical(boundaryMap);
        %----------------------------------------------
        
        [X, Y] = find(BoundaryL == 1);
        plot(Y, X+rSplit, 'y+');
        [X, Y] = find(BoundaryR == 1);
        plot(Y+cSplit, X+rSplit, 'g+');
    else
        rHorizon = rSplit;
        sz = [nRow - rHorizon + 1, 1];
        cBoundaryL = repmat(10, sz);
        cBoundaryR = repmat(nCol - 10, sz);
        % +/- 10 for avoiding mistaking boudaries as lane markings 
        
        %----------------------------------------------
        for i=1:nCol	
            for j=1:nRow	
                if j < rHorizon	
                    boundaryMap(j,i) = 0;	
                end	
            end	
        end	
        boundaryMap = logical(boundaryMap);
        %----------------------------------------------
        
    end

end

function line = bwFitLine(BW, Theta)
% fit line using non-zero pixels in a binary image by Hough Transform

	[H,theta,rho] = hough(BW, 'Theta', Theta);
    
    %% Show Hough Transform Result.
    imshow(H,[],'XData',theta,'YData',rho,'InitialMagnification','fit');
    xlabel('\theta'), ylabel('\rho');
    axis on, axis normal;
    
	P = houghpeaks(H, 1);
    
	lines = houghlines(BW,theta,rho,P, 'MinLength',10, 'FillGap',570);
	
	if length(lines) > 1, lines = lines(1); end

    if isempty(lines), line = []; return; end
    
	line = LineObj(lines.point1, lines.point2);
    
    % Plot peak points
    hold on;
    plot(theta(P(:,2)),rho(P(:,1)),'s','color','white');
end


function missM = dtLaneMarking(Img,rHorizon,cBoundaryL,cBoundaryR,thetaSet)

%%  Region of interest adjustment
    %ROI = Img(rHorizon:end,:,1);
    ROI = Img(rHorizon:end,:,:);
    V_ROI = im2double(max(ROI, [], 3)); % Note!

%%  Lane-marking feature extraction
    [nRow, nCol, ~] = size(ROI);
    I2 = zeros(nRow, nCol);
    
    for r = 1 : nRow
        mw = ceil(5 * r / nRow); % marking width
        for c =   ceil(max(cBoundaryL(r),   1) + 5*mw):1 ...
                :floor(min(cBoundaryR(r),nCol) - 5*mw)
            I2(r, c) = 2*V_ROI(r,c) - (V_ROI(r,c-mw) + V_ROI(r,c+mw)) ...
                                 - abs(V_ROI(r,c-mw) - V_ROI(r,c+mw));
        end
    end
    
    Marking = im2bw(I2, graythresh(I2(I2 ~= 0)));

    imdump(3, ROI, I2, Marking);

%% Lane model fitting
    houghM = figure;
    line = bwFitLine(Marking, thetaSet);
    
    imdump(3, houghM);
    close(houghM);
    
    missM = isempty(line);
    if missM
        disp('Fail in lane markings detection.');
    else
        PointS = [line.row(1), rHorizon]; % start point
        PointE = [line.row(nRow), nRow+rHorizon]; % end point
        lineMarking = LineObj(PointS, PointE);
        
        % Plot
        lineMarking.plot('LineWidth',3,'Color','red');
    end
end

function side = lineSide(p, a, b)
    side = (p(1) - a(1)) * (b(2) - a(2)) - (p(2) - a(2)) * (b(1) - a(1));
end