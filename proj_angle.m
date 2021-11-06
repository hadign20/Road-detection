function alpha = proj_angle(xs,ys)
    %PROJ_ANGLE calculate the projection angle
    %   Detailed explanation goes here
    
    %-- moment 1 (C-1) paper: Shadow effect weakening based on intrinsic image extraction with effective projection of logarithmic domain for road scene
    c = cov(xs,ys);
    cov_xy = c(1,2);
    alpha1 = atan(sign(cov_xy))*(abs(sum(ys(:)))./ abs(sum(xs(:))));
    
    %-- paper: Road detection based on illuminant invariance and quadratic estimation
    var_x = var(xs(:),'omitnan'); var_y = var(ys(:),'omitnan');
    alpha_x = atan(var_x/cov_xy); alpha_y = atan(var_y/cov_xy);
    alpha2 = .5 * (alpha_x + alpha_y);
    
    %-- moment 3 (C-3) paper: Shadow effect weakening based on intrinsic image extraction with effective projection of logarithmic domain for road scene
    xs3 = xs.^3; ys3 = ys.^3;
    s_x = (1/numel(xs)) * sum(xs3(:));  s_y = (1/numel(ys)) * sum(ys3(:));
    alpha3 = atan(s_y^(1/3) / s_x^(1/3));
    
    %-- pca
    points = [xs(:) ys(:)];
    coeff = pca(points);
    alpha4 = atan(coeff(2,1)/coeff(1,1));
    
    alphas = [alpha1 alpha2 alpha3 alpha4];
    alpha = median(alphas);
    
end

