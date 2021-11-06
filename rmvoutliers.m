function [result] = rmvoutliers(x, y, tol)
% rmoutliers: main function,
% removes outliers with absolute value > tol(a scalar)
% out of [x,y] series
dist = calcDist(x, y);
mean = calcMean(dist);
result = zeros(2,length(x));

for i = 1:length(dist)
    result(:,i) = [x(i), y(i)];
    if abs(dist(i) - mean) > tol
        result(:,i) = [-1, -1];
    end  
end

result(result == -1) = [];
result = reshape(result, 2, []);

end



function [dist] = calcDist(x, y)
%calcDist: calculates absolute value of
% each pair of elements in [x, y]
% (the distance from the origin)
dist = sqrt(x.^2 + y.^2);

end



function [mean] = calcMean(dist)
%calcMean: average of input array
mean = sum(dist) / length(dist);

end