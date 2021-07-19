% https://www.mathworks.com/matlabcentral/answers/376794-how-to-get-pixels-intensities-on-a-circles-with-radii-r-for-an-image-with-selective-angles
clear
close all
removeNan = 1;
titleStr = 'rocks, fast-flow, shallow-H';
imSaveFile = 'fast_shallow_rocks.png';
filename ='ZOOMED_mean_2DFFT_slopeAzi_rocks_fastFlow_ShallowH_test2.mat';
% n_contours = 9
% displayQuantity_str = 'Integral normalized $$\left <\log^2\left |  FFT\left(\tan^{-1}\frac{S_{spanwise}}{S_{streamwise}}\right)\right |\right >$$';
%% Load the flow case, normalize by its integral, remove DC (if you choose)
load(filename);
case_string = '';%'corals, Fast, Shallow: Case6';
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
%%
abs_angles = {20, 45, 70};
k_quads = {4,length(abs_angles)};
data_quads = {4,length(abs_angles)};
angle_colors = {'g','m','b'};
quad_markers = {'o', '+', '^', 's'};

close all
f = figure(1);
subplot(1,3,1)
imagesc(x_corner, y_corner, I_zoom)
colormap(flipud(inferno(256)))
colorbar()
axis square
% shading interp;
hold on

% 
hline = refline([tand(abs_angles{1}) 0]);
hline.XData(1) = 0;
hline.YData(1) = 0;
hline.Color = angle_colors{1};
hline.LineStyle = '-';
hline.LineWidth = 1;

hline = refline([tand(abs_angles{1}) 0]);
hline.XData(2) = 0;
hline.YData(2) = 0;
hline.Color = angle_colors{1};
hline.LineStyle = '-';
hline.LineWidth = 1;

hline = refline([-tand(abs_angles{1}) 0]);
hline.XData(1) = 0;
hline.YData(1) = 0;
hline.Color = angle_colors{1};
hline.LineStyle = '-';
hline.LineWidth = 1;

hline = refline([-tand(abs_angles{1}) 0]);
hline.XData(2) = 0;
hline.YData(2) = 0;
hline.Color = angle_colors{1};
hline.LineStyle = '-';
hline.LineWidth = 1;
%
hline = refline([tand(abs_angles{2}) 0]);
hline.XData(2) = 0;
hline.YData(2) = 0;
hline.Color =angle_colors{2};
hline.LineStyle = '-';
hline.LineWidth = 1;

hline = refline([tand(abs_angles{2}) 0]);
hline.XData(1) = 0;
hline.YData(1) = 0;
hline.Color = angle_colors{2};
hline.LineStyle = '-';
hline.LineWidth = 1;
% 
hline = refline([-tand(abs_angles{2}) 0]);
hline.XData(2) = 0;
hline.YData(2) = 0;
hline.Color = angle_colors{2};
hline.LineStyle = '-';
hline.LineWidth = 1;

hline = refline([-tand(abs_angles{2}) 0]);
hline.XData(1) = 0;
hline.YData(1) = 0;
hline.Color = angle_colors{2};
hline.LineStyle = '-';
hline.LineWidth = 1;
% 
hline = refline([tand(abs_angles{3}) 0]);
hline.XData(1) = 0;
hline.YData(1) = 0;
hline.XData(2) = hline.XData(2);
hline.YData(2) = hline.YData(2);
hline.Color = angle_colors{3};
hline.LineStyle = '-';
hline.LineWidth = 1;
% 
hline = refline([tand(abs_angles{3}) 0]);
hline.XData(1) = hline.XData(1);
hline.YData(1) = hline.YData(1);
hline.XData(2) = 0;
hline.YData(2) = 0;
hline.Color = angle_colors{3};
hline.LineStyle = '-';
hline.LineWidth = 1;
%
hline = refline([-tand(abs_angles{3}) 0]);
hline.XData(1) = 0;
hline.YData(1) = 0;
hline.XData(2) = hline.XData(2);
hline.YData(2) = hline.YData(2);
hline.Color = angle_colors{3};
hline.LineStyle = '-';
hline.LineWidth = 1;
% 
hline = refline([-tand(abs_angles{3}) 0]);
hline.XData(1) = hline.XData(1);
hline.YData(1) = hline.YData(1);
hline.XData(2) = 0;
hline.YData(2) = 0;
hline.Color = angle_colors{3};
hline.LineStyle = '-';
hline.LineWidth = 1;

text(325,-1845*2,'Q4','interpreter','latex', 'fontsize',12)
text(-1845*2, -900,'Q3','interpreter','latex', 'fontsize',12)
text(-1020, 1671*2,'Q2','interpreter','latex', 'fontsize',12)
text(1500*2, 845,'Q1','interpreter','latex', 'fontsize',12)

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
xlabel('$$k_x$$ centered at 0 $$cm^{-1}$$', 'interpreter','latex', 'fontsize',12)
ylabel('$$k_y$$ centered at 0 $$cm^{-1}$$', 'interpreter','latex', 'fontsize',12)
title({case_string,...
    'integral normalized $$\left <\log^2\left |  FFT\left(\tan^{-1}\frac{S_{spanwise}}{S_{streamwise}}\right)\right |\right >$$'},...
    'interpreter','latex', 'fontsize',11)
xlim(x_corner)
ylim(y_corner)
% axis tight

%% get the values of I_zoom at any line at angle theta
for p  = 1:1:length(abs_angles) 
    %Q1,4 loop -- for the same ABSOLUTE angle
    for k = -1:2:1
        theta = k * abs_angles{p};
        k_mag_q = zeros(mx/2,1);
        quad_vals = zeros(mx/2,1);
        for i = mx/2+1:1:mx
            kx_val = kx(1,i);
            ky_val = tand(theta)*kx_val;
            if ky_val >  y_corner(2) && ky_val <  y_corner(1)
                k_mag_q(i - mx/2 ,1) = nan;
                quad_vals(i - mx/2,1) = nan;
                continue;
            end
            k_mag_q(i - mx/2 ,1) = sqrt(kx_val^2 + ky_val^2);
            data_val = interp1(ky', I_zoom(:,i), ky_val);
            quad_vals(i - mx/2,1) = data_val;
        end
        k_quads{mod(k,5), p} = k_mag_q;
        data_quads{mod(k,5), p} = quad_vals;
    end
 
    % Q2,3 for the same ABSOLUTE angle
    for k = -1:2:1
        theta = k * abs_angles{p};
        k_mag_q = zeros(mx/2,1);
        quad_vals = zeros(mx/2,1);
        for i = mx/2:-1:1
            kx_val = kx(1,i);
            ky_val = tand(theta)*kx_val;
            if ky_val >  y_corner(2) && ky_val <  y_corner(1)
                k_mag_q(mx/2 - i  + 1 ,1) = nan;
                quad_vals(mx/2 - i + 1,1) = nan;
                continue;
            end
            k_mag_q(mx/2 - i + 1 ,1) = sqrt(kx_val^2 + ky_val^2);
            data_val = interp1(ky', I_zoom(:,i), ky_val);
            quad_vals(mx/2 - i + 1,1) = data_val;
        end
        if k == -1
            k_quads{2, p} = k_mag_q;
            data_quads{2, p} = quad_vals;
        else
            k_quads{3, p} = k_mag_q;
            data_quads{3, p} = quad_vals;
        end
    end
end
%% plot the quadrant lines for different angles -- linear x axis

subplot(1,3,2)
for i = 1:1:3
    for j = 1:1:4
        plot(k_quads{j,i}, data_quads{j,i},quad_markers{i},...
            'MarkerEdgeColor', angle_colors{i});
        hold on
    end
end
legend(sprintf('$\\pm %d^{\\circ}$',abs_angles{1}),'','',''...
        , sprintf('$\\pm %d^{\\circ}$',abs_angles{2}),'','',''...
        , sprintf('$\\pm %d^{\\circ}$',abs_angles{3}),'','',''...
        ,'interpreter','latex', 'fontsize',10)
grid on
axis square
xlabel('$$\sqrt{k_x^2 + k_y^2}$$ $$cm^{-1}$$', ...
    'interpreter','latex', 'fontsize',14)


%% plot the quadrant lines for different angles -- log x axis, and fit
subplot(1,3,3)
for i = 1:1:3
    for j = 1:1:4
        semilogx(k_quads{j,i}, data_quads{j,i},quad_markers{i},...
            'MarkerEdgeColor', angle_colors{i});
        hold on
    end
end
grid on
axis square
xlabel('$$\sqrt{k_x^2 + k_y^2}$$ $$cm^{-1}$$', ...
    'interpreter','latex', 'fontsize',14)

sgtitle(titleStr,'interpreter','latex')


% Set up fittype and options. plot the data fit\
lim1 = 0.025;
lim2 = 0.25;
k = k_quads{4,2};
k = k(floor(lim1*length(k)):floor(lim2*length(k)),:);
klog = log(k);
vals = data_quads{4,2};
vals = vals(floor(lim1*length(vals)):floor(lim2*length(vals)),:);

% Set up fittype and options.
[xData, yData] = prepareCurveData( klog, vals );
ft = fittype( 'poly1' );
[fitresult, gof] = fit( xData, yData, ft );
% figure(3);
z = semilogx(k, fitresult.p2 + fitresult.p1 * klog,'k-');
z.LineWidth = 1;
%
legend(sprintf('$\\pm %d^{\\circ}$',abs_angles{1}),'','',''...
        , sprintf('$\\pm %d^{\\circ}$',abs_angles{2}),'','',''...
        , sprintf('$\\pm %d^{\\circ}$',abs_angles{3}),'','',''...
        ,sprintf('$e^y = {%.1f} x^{%.2E}$',exp(fitresult.p2), fitresult.p1)...
        ,'interpreter','latex', 'fontsize',10)
f.Position = [5 390 1338 420];
saveas(gcf,['FLIR_Camera/lobe_slope_azimuth_plots/',imSaveFile])