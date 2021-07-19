% https://www.mathworks.com/matlabcentral/answers/376794-how-to-get-pixels-intensities-on-a-circles-with-radii-r-for-an-image-with-selective-angles
clear
removeNan = 1;
% n_contours = 9
% displayQuantity_str = 'Integral normalized $$\left <\log^2\left |  FFT\left(\tan^{-1}\frac{S_{spanwise}}{S_{streamwise}}\right)\right |\right >$$';
%% Load the flow case, normalize by its integral, remove DC (if you choose)
load('ZOOMED_mean_2DFFT__slopeAzi_corals_DIST172cm.mat');
case_string = 'corals, Fast, Shallow: Case6';
% flowCase_str = [upper(BEDFORM), ': ', upper(FLOW_SPEED), ' flow - ', upper(SUBMERGENCE), ' depth'];
% title_string = {displayQuantity_str, ' ', flowCase_str};

I = slopeMag_hat_mag_mean;
[nx,ny] = size(I) ; % x is the cols, y: rows
% view the zoomed in image
lim = 250;
delta = 3;
I_zoom = I(nx/2 - lim/2:nx/2 + lim/2+ delta, ...
                ny/2 - lim/2:ny/2 + lim/2 +delta);
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
subplot(1,3,1)
imagesc(x_corner, y_corner, I_zoom)
colormap(flipud(inferno(256)))
colorbar()
axis square
% shading interp;
hold on

hline = refline([1 0]);
hline.XData(2) = 0;
hline.YData(2) = 0;
hline.Color = 'm';
hline.LineStyle = '--';
hline.LineWidth = 1;

hline = refline([1 0]);
hline.XData(1) = 0;
hline.YData(1) = 0;
hline.Color = 'm';
hline.LineStyle = '-';
hline.LineWidth = 1;

hline = refline([-1 0]);
hline.XData(2) = 0;
hline.YData(2) = 0;
hline.Color = 'b';
hline.LineStyle = '-';
hline.LineWidth = 1;

hline = refline([-1 0]);
hline.XData(1) = 0;
hline.YData(1) = 0;
hline.Color = 'b';
hline.LineStyle = '--';
hline.LineWidth = 1;

text(325,-1845*2,'Q1','interpreter','latex', 'fontsize',12)
text(-1845*2, -900,'Q2','interpreter','latex', 'fontsize',12)
text(-1020, 1671*2,'Q3','interpreter','latex', 'fontsize',12)
text(1500*2, 845,'Q4','interpreter','latex', 'fontsize',12)

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
title({case_string,...
    'integral normalized $$\left <\log^2\left |  FFT\left(\tan^{-1}\frac{S_{spanwise}}{S_{streamwise}}\right)\right |\right >$$'},...
    'interpreter','latex', 'fontsize',11)

%% +/- 45 degree lines 
plus45 = zeros(mx,1);
k_mag_minus45 = zeros(mx,1);
k_mag_plus45 = zeros(mx,1);
minus45 = zeros(mx,1);
for t = 1:1:mx
    k_mag_minus45(t) = sqrt(kx(t)^2 + ky(t)^2);
    k_mag_plus45(t) = sqrt(kx(mx-t+1)^2 + ky(t)^2);
    minus45(t) = I_zoom(t,t);
    plus45(t) = I_zoom(mx-t+1,t);
end
quad1 = plus45(mx/2+2:end);
quad2 = minus45(1:mx/2-1);
quad3 = plus45(1:mx/2-1);
quad4 = minus45(mx/2+2:end);
k_mag_q1 = k_mag_plus45(mx/2+2:end);
k_mag_q2 = k_mag_minus45(1:mx/2-1);
k_mag_q3 = k_mag_plus45(1:mx/2-1);
k_mag_q4 = k_mag_minus45(mx/2+2:end);

%% plot the +/- 45 degree lines -- linear x axis
subplot(1,3,2)
plot(k_mag_q1, quad1, 'b--'); 
hold on;
plot(k_mag_q2, quad2, 'm--'); 
plot(k_mag_q3, quad3, 'b-'); 
plot(k_mag_q4, quad4, 'm-'); 
% Set up fittype and options.
ft = fittype( 'power2' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
[xData, yData] = prepareCurveData( k_mag_plus45, plus45 );
[fitresult, gof] = fit(xData, yData, ft, opts );
z = plot(fitresult,'k-');
z.LineWidth = 1;


legend('Q1', 'Q2','Q3', 'Q4',...
    sprintf('$C_1 k^{%.2f} + C_2~;r^2 = %.2f$',...
    fitresult.b,...
    gof.rsquare),...
    'interpreter','latex', 'fontsize',10)
title({'fall off: +/- 45 degree lines', 'linear x axis'},'interpreter','latex', 'fontsize',12)
grid on
axis square
xlabel('$$\sqrt{k_x^2 + k_y^2}$$ $$cm^{-1}$$', 'interpreter','latex', 'fontsize',14)


%% -- logarithmic x axis
subplot(1,3,3);
semilogx(k_mag_q1, quad1, 'b--'); 
hold on;
semilogx(k_mag_q2, quad2, 'm--'); 
semilogx(k_mag_q3, quad3, 'b-'); 
semilogx(k_mag_q4, quad4, 'm-'); 
z = plot(fitresult,'k-');
z.LineWidth = 1;


legend('Q1', 'Q2','Q3', 'Q4',...
    sprintf('$C_1 k^{%.2f} + C_2~;r^2 = %.2f$',...
    fitresult.b,...
    gof.rsquare),...
    'interpreter','latex', 'fontsize',10)
title({'fall off: +/- 45 degree lines', 'log x axis'},'interpreter','latex', 'fontsize',12)
grid on
axis square
xlabel('$$\sqrt{k_x^2 + k_y^2}$$ $$cm^{-1}$$', 'interpreter','latex', 'fontsize',14)

