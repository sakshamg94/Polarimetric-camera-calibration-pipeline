% https://www.mathworks.com/matlabcentral/answers/376794-how-to-get-pixels-intensities-on-a-circles-with-radii-r-for-an-image-with-selective-angles
close all
figure(1);
hold on
removeNan = 0;
displayQuantity_str = 'Integral normalized $$\left <\log^2\left |  FFT\left(\tan^{-1}\frac{S_{spanwise}}{S_{streamwise}}\right)\right |\right >$$';
%% SLOW DEEP
load('ZOOMED_mean_2DFFT_slopeAzi_dunes_slowFlow_DeepH_test2.mat');
I = slopeMag_hat_mag_mean;
[nx,ny,d] = size(I) ; % x is the cols, y: rows
% view the zoomed in image
lim = 100;
delta = 3;
I_zoom = I(nx/2 - lim/2:nx/2 + lim/2+ delta, ny/2 - lim/2:ny/2 + lim/2 +delta);
[mx, my] = size(I_zoom); 
kx = -mx/2+0.5:1:mx/2-0.5;
ky = -my/2+0.5:1:my/2-0.5;
integral = trapz(ky,trapz(kx,I_zoom,2));
I_zoom = I_zoom/integral;

center = [mx/2 , my/2];% center of the circle;
xc = center(1);
yc = center(2);
if removeNan==1
    I_zoom(xc,:) = nan;
    I_zoom(:,yc) = nan;
end

% disaplay the Zoomed in image
subplot(2,2,1);
imshow(I_zoom, []) ; % minmax color scaling for gray images with doubles
hold on
% axis on
xlabel('$$k_x$$ centered at 0 $$px^{-1}$$', 'interpreter','latex')
ylabel('$$k_y$$ centered at 0 $$px^{-1}$$', 'interpreter','latex')
axis square;
m=256;
cm_inferno=inferno(m);
colormap(flipud(cm_inferno));
colorbar;
% define your circle

r = [50, 40, 30, 20, 10, 5, 1, 0.5];
colors = num2cell(hsv(length(r)),2);%{[0.5,0.5,0], 'black', 'green', 'magenta', 'blue', 'red', 'cyan'};
flowCase_str = [BEDFORM,' ', FLOW_SPEED,' ',SUBMERGENCE];
title_string = {flowCase_str,  displayQuantity_str};
% In polar coordinates
angles = 0:1:360 ; % location in degrees reckoned from x axis -- clockwise
% polar_coord = [r(1)*ones(1, length(angles)); angles*pi/180] ;
% In cartesian coordinates
    % create teh query points
Xq = zeros(length(r), length(angles));
Yq = zeros(length(r), length(angles));
for k =1:length(r)
    Xq(k,:) = xc(1)+r(k)*cosd(angles) ;
    Yq(k,:) = yc(1)+r(k)*sind(angles) ;
    plot(Xq(k,:),Yq(k,:),'.','Color',colors{k}) ;
end
title(title_string, 'interpreter','latex', 'fontsize',11)
hold off


%Do interpolation to get pixels 
circ_vals = zeros(length(r), length(angles));
[X,Y] = meshgrid(1:mx,1:my);

% display the second subplot of the values along the chosen circle
subplot(2,2,3);
hold on

for k  = 1:length(r)
    circ_vals(k,:) = interp2(X,Y,I_zoom(:,:),Xq(k,:),Yq(k,:)) ; 
    plot(circ_vals(k,:), 'color',colors{k}, 'LineWidth',1.1);
end
ylabel(title_string, 'interpreter','latex', 'fontsize',11)
xlabel('Image azimuth in degrees (reckoned from x axis clockwise)')
%% FAST SHALLOW
load('ZOOMED_mean_2DFFT_slopeAzi_dunes_fastFlow_ShallowH_test2.mat');
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
if removeNan==1
    I_zoom(xc,:) = nan;
    I_zoom(:,yc) = nan;
end
kx = -mx/2+0.5:1:mx/2-0.5;
ky = -my/2+0.5:1:my/2-0.5;
integral = trapz(ky,trapz(kx,I_zoom,2));
I_zoom = I_zoom/integral;

% disaplay the Zoomed in image
subplot(2,2,2);
imshow(I_zoom, []) ; % minmax color scaling for gray images with doubles
hold on
% axis on
xlabel('$$k_x$$ centered at 0 $$px^{-1}$$', 'interpreter','latex')
ylabel('$$k_y$$ centered at 0 $$px^{-1}$$', 'interpreter','latex')
axis square;
m=256;
cm_inferno=inferno(m);
colormap(flipud(cm_inferno));
colorbar;
% define your circle

r = [50, 40, 30, 20, 10, 5, 1, 0.5];
colors = num2cell(hsv(length(r)),2);%{[0.5,0.5,0], 'black', 'green', 'magenta', 'blue', 'red', 'cyan'};
flowCase_str = [BEDFORM,' ', FLOW_SPEED,' ',SUBMERGENCE];
title_string = {flowCase_str, displayQuantity_str};

% In polar coordinates
angles = 0:.1:360 ; % location in degrees reckoned from x axis -- clockwise
% polar_coord = [r(1)*ones(1, length(angles)); angles*pi/180] ;
% In cartesian coordinates
    % create teh query points
Xq = zeros(length(r), length(angles));
Yq = zeros(length(r), length(angles));
for k =1:length(r)
    Xq(k,:) = xc(1)+r(k)*cosd(angles) ;
    Yq(k,:) = yc(1)+r(k)*sind(angles) ;
    plot(Xq(k,:),Yq(k,:),'.','color',colors{k}) ;
end
title(title_string, 'interpreter','latex', 'fontsize',11)
hold off


%Do interpolation to get pixels 
circ_vals = zeros(length(r), length(angles));
[X,Y] = meshgrid(1:mx,1:my);

% display the second subplot of the values along the chosen circle
subplot(2,2,4);
hold on

for k  = 1:length(r)
    circ_vals(k,:) = interp2(X,Y,I_zoom(:,:),Xq(k,:),Yq(k,:)) ; 
    plot(angles,circ_vals(k,:), 'color',colors{k}, 'LineWidth',1);
end
ylabel(title_string, 'interpreter','latex', 'fontsize',11)
xlabel('Image azimuth in degrees (reckoned from x axis clockwise)')
