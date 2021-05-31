% https://www.mathworks.com/matlabcentral/answers/376794-how-to-get-pixels-intensities-on-a-circles-with-radii-r-for-an-image-with-selective-angles
removeNan = 1;
% n_contours = 9
% displayQuantity_str = 'Integral normalized $$\left <\log^2\left |  FFT\left(\tan^{-1}\frac{S_{spanwise}}{S_{streamwise}}\right)\right |\right >$$';
%% Load the flow case, normalize by its integral, remove DC (if you choose)
load('ZOOMED_mean_2DFFT__slopeAzi_corals_DIST247cm.mat');
% flowCase_str = [upper(BEDFORM), ': ', upper(FLOW_SPEED), ' flow - ', upper(SUBMERGENCE), ' depth'];
% title_string = {displayQuantity_str, ' ', flowCase_str};

I = slopeMag_hat_mag_mean;
[nx,ny] = size(I) ; % x is the cols, y: rows
% view the zoomed in image
lim = 100;
delta = 3;
I_zoom = I(nx/2 - lim/2:nx/2 + lim/2+ delta, ny/2 - lim/2:ny/2 + lim/2 +delta);
[mx, my] = size(I_zoom); 
center = [mx/2 , my/2];% center of the circle;
xc = center(1);
yc = center(2);
kx = (-mx/2+0.5:1:mx/2-0.5)*43.4;
ky = (-my/2+0.5:1:my/2-0.5)*43.4;
integral = trapz(ky,trapz(kx,I_zoom,2));
I_zoom = I_zoom/integral;
x_corner = [min(kx), max(kx)];
y_corner = [min(ky), max(ky)];

%%
windowWidth = 3 ;
kernel = ones(windowWidth) / windowWidth^2;
I = filter2(kernel, I_zoom);

if removeNan==1
    I(xc,yc) = nan;
    I(xc,:) = nan;
    I(:,yc) = nan;
    I_zoom(xc,yc) = nan;
    I_zoom(xc,:) = nan;
    I_zoom(:,yc) = nan;
end
%
close all
figure(1);
imagesc(x_corner, y_corner, I_zoom)
colormap(flipud(inferno(256)))
colorbar()
axis square
% shading interp;
hold on


% dashed lines
% yline(-0.5, '--k', 'LineWidth',2)
% xline(-0.5, '--k', 'LineWidth', 2)

% contour plot
I(1:3,:) = nan;
I(end-3:end,:) = nan;
I(:,1:3) = nan;
I(:, end-3:end) = nan;
[X,Y] = meshgrid(kx,ky);
% [M,ct] = contour(X,Y,I,n_contours);%,'LevelList', 0:1e-5:0.01);
% ct.LineWidth = 2;
% ct.LineColor = 'red';

% overlay gradient lines
% d= 4;
% [DX,DY] = gradient(filter2(kernel,filter2(kernel,I(1:d:end,1:d:end))));
% quiver(X(1:d:end,1:d:end),Y(1:d:end,1:d:end), DX, DY, ...
%     'ShowArrowHead', 'off', 'LineWidth',1.3, 'autoscale','on','AutoScaleFactor',2)
% 
% axes labelling
xlabel('$$k_x$$ centered at 0 $$cm^{-1}$$', 'interpreter','latex', 'fontsize',14)
ylabel('$$k_y$$ centered at 0 $$cm^{-1}$$', 'interpreter','latex', 'fontsize',14)
title("Corals, fast, shallow - case V", 'interpreter','latex', 'fontsize',14)