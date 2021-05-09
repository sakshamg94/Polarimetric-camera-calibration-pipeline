% https://www.mathworks.com/matlabcentral/answers/376794-how-to-get-pixels-intensities-on-a-circles-with-radii-r-for-an-image-with-selective-angles
removeNan = 1;
displayQuantity_str = 'Integral normalized $$\left <\log^2\left |  FFT\left(\tan^{-1}\frac{S_{spanwise}}{S_{streamwise}}\right)\right |\right >$$';
%% Load the flow case, normalize by its integral, remove DC (if you choose)
load('ZOOMED_mean_2DFFT_slopeAzi_canopy_slowFlow_DeepH_test2.mat');
flowCase_str = [upper(BEDFORM), ': ', upper(FLOW_SPEED), ' flow - ', upper(SUBMERGENCE), ' depth'];
title_string = {displayQuantity_str, ' ', flowCase_str};

I = slopeMag_hat_mag_mean;
[nx,ny,d] = size(I) ; % x is the cols, y: rows
% view the zoomed in image
lim = 100;
delta = 3;
I_zoom = I(nx/2 - lim/2:nx/2 + lim/2+ delta, ny/2 - lim/2:ny/2 + lim/2 +delta);
[mx, my] = size(I_zoom); 
center = [mx/2 , my/2];% center of the circle;
xc = center(1);
yc = center(2);
kx = -mx/2+0.5:1:mx/2-0.5;
ky = -my/2+0.5:1:my/2-0.5;
integral = trapz(ky,trapz(kx,I_zoom,2));
I_zoom = I_zoom/integral;
if removeNan==1
    I_zoom(xc,yc) = nan;
    I_zoom(xc,:) = nan;
    I_zoom(:,yc) = nan;
end
%% 
close all
thresh = 1.2e-4;
disp(max(max(I_zoom)))
I = I_zoom;%imadjust(I_zoom); 
% how does this work under the hood for contrast enhancement?
ax = figure(1);
x_corner = [min(kx), max(kx)];
y_corner = [min(ky), max(ky)];
imagesc(x_corner, y_corner, I)
hold on
axis square
colormap(flipud(inferno(256)))
colorbar()
shading interp;
xlabel('$$k_x$$ centered at 0 $$px^{-1}$$', 'interpreter','latex', 'fontsize',13)
ylabel('$$k_y$$ centered at 0 $$px^{-1}$$', 'interpreter','latex', 'fontsize',13)
title(title_string, 'interpreter','latex', 'fontsize',11)
% 
[x_convex_left, y_convex_left] = getpts(ax); % U structure
[x_convex_right, y_convex_right] = getpts(ax); % U structure
[x_concave_left,y_concave_left] = getpts(ax); % inverted-U structure
[x_concave_right,y_concave_right] = getpts(ax); % inverted-U structure

location = '../FLIR_Camera/matlab circular profile plots/';
flow_name = [upper(BEDFORM), '_', upper(FLOW_SPEED), 'flow_', upper(SUBMERGENCE), 'depth'];
filename1 = [location, 'slopeAzi_IntegralNormed_', flow_name, '.png'];
saveas(gcf, filename1);
%%
figure(2);
imagesc(x_corner, y_corner, I);
axis square
hold on
colormap(flipud(inferno(256)))
colorbar()
shading interp;
yline(-0.5, '--k', 'LineWidth',2)
xline(-0.5, '--k', 'LineWidth', 2)
% I_zoom(I_zoom > thresh) = 1; %max(max(I_zoom));

% select 3-4 points including 0,0 to lie on the polynomial (above and
% below the ky=0 line -- select 3 above and 3 below
% can this step be automated to eliminate human judgement error 
% and to make the fit repeatable? change in intensity in a region -- like
% an edge detector?

% fit a ploynomial of order 2 through these points
% p_convex  = polyfit(x_convex,  y_convex,  2);
% p_concave = polyfit(x_concave, y_concave, 2);
p_convex_left  = polyfit(x_convex_left,  y_convex_left,  1);
p_convex_right  = polyfit(x_convex_right,  y_convex_right,  1);
p_concave_left = polyfit(x_concave_left, y_concave_left, 1);
p_concave_right = polyfit(x_concave_right, y_concave_right, 1);

% evaluate the polynomial on the kx, ky grid and plot
kx_poly_convex_left = min(x_convex_left):1:max(x_convex_left);
plot(kx_poly_convex_left, polyval(p_convex_left, kx_poly_convex_left), 'b-', 'LineWidth',2)

kx_poly_convex_right = min(x_convex_right):1:max(x_convex_right);
plot(kx_poly_convex_right, polyval(p_convex_right, kx_poly_convex_right), 'b-', 'LineWidth',2)

kx_poly_concave_left = min(x_concave_left):1:max(x_concave_left);
plot(kx_poly_concave_left, polyval(p_concave_left, kx_poly_concave_left), 'b-', 'LineWidth',2)

kx_poly_concave_right = min(x_concave_right):1:max(x_concave_right);
plot(kx_poly_concave_right, polyval(p_concave_right, kx_poly_concave_right), 'b-', 'LineWidth',2)

xlabel('$$k_x$$ centered at 0 $$px^{-1}$$', 'interpreter','latex', 'fontsize',13)
ylabel('$$k_y$$ centered at 0 $$px^{-1}$$', 'interpreter','latex', 'fontsize',13)

title(title_string, 'interpreter','latex', 'fontsize',11)

filename2 = [location, 'slopeAzi_IntegralNormed_Curves_', flow_name, '.png'];
saveas(gcf, filename2);
%% plot the bounding hull of the cloud
% subplot(1,3,3)
% hold on
% % observe the difference in tilt of the 2 lobes above and below the ky = 0 line
% BW = im2bw(I);
% BW_filled=imfill(BW, 'holes');
% imshow(I)
% boundaries = bwboundaries(BW_filled);
% for k =1:length(boundaries)
%     b = boundaries{k};
%     plot(b(:,2), b(:,1)', 'g', 'LineWidth', 3); hold on;
% end
