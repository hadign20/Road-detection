function intr = intrinsic(inImg, inDeb)
    %INTRINSIC returns intrinsic grayscale image of a multi-channel image
    %   Detailed explanation goes here
    
    [R, G, B] = imsplit(inImg);
    gm = nthroot(immultiply(R,immultiply(G,B)),3); %geometric mean
    
    %div_x = imdivide(R,gm); div_y = imdivide(B,gm);
    div_x = imdivide(R,G); div_y = imdivide(B,G);
    if inDeb == 1, figure, imshow(div_x,[]); figure, imshow(div_y,[]); end
    
    X = log(div_x); Y = log(div_y); 
    X(isinf(X)|isnan(X))=0; Y(isinf(Y)|isnan(Y))=0;
    if inDeb == 1, figure, imshow(X,[]); figure, imshow(Y,[]); end
    
    X_s = imsubtract(X, mean2(X)); Y_s = imsubtract(Y, mean2(Y));
    X_s(isnan(X_s))=0; Y_s(isnan(Y_s))=0;
    %if inDeb == 1, figure, imshow(X_s,[]); figure, imshow(Y_s,[]); end
    
    %-- calculate alpha
        %-- remove outliers using matlab function
        %XY = rmoutliers([X_s(:), Y_s(:)], 'median');
        %Xs = XY(:,1); Ys = XY(:,2);
        %-- remove outliers using custom function
        %XY = rmvoutliers(X_s(:), Y_s(:), 1);
        %Xs = XY(1,:); Ys = XY(2,:);
        
    alpha = proj_angle(X_s, Y_s);
    
    %-- draw plot
    if inDeb == 1
        %-- select an roi
%         imshow(inImg);
%         rect = drawrectangle();
%         pos = get(rect, 'Position');
%         left = pos(1); right = pos(1) + pos(3); top = pos(2); bottom = pos(2) + pos(4);
        %-- draw points
        figure
             s_main = scatter(X(:),Y(:), 0.8, 'filled','DisplayName', 'pixels');
%             distfromzero = sqrt(X.^2 + Y.^2);
%             s_main.AlphaData = distfromzero;
%             s_main.MarkerFaceAlpha = 'flat';
%             hold on;
%            s_roi = scatter(X(left:right),Y(top:bottom), 2, 'r', 'filled');
            xlabel('log(R/G)');
            ylabel('log(B/G)');
        hold on,
        %-- draw alpha line
        x1 = -10; x2 = 10; y1 = x1 * tan(alpha); y2 = x2 * tan(alpha);
        plot([x1 x2],[y1 y2],'LineWidth',2, 'DisplayName', 'alpha'); xlim([-5 5]), ylim([-5 5]); legend, hold off;
    end
    
    %-- grayscale intrinsic image
    intr = (cos(alpha) * X) + (sin(alpha) * Y);
    if inDeb == 1, figure, imshow(intr,[]); end
    intr_orth = (cos(alpha + pi) * X) + (sin(alpha + pi) * Y);
    


    %-- test for all alpha values
%     position =  [100 50];
    %result = insertText(intr,position,alpha/pi,'AnchorPoint','RightBottom');
    %figure, imshow(result,[]);
%     for alpha = 0:0.1*pi:2*pi
%         intr = (cos(alpha) * X) + (sin(alpha) * Y);
%         if inDeb == 0 
%             %RGB = insertText(intr,position,alpha/pi,'AnchorPoint','LeftBottom');
%             figure, imshow(intr,[]);
%         end
%     end

end

