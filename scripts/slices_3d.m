load('ZOOMED_mean_3DFFT_corals_fastFlow_ShallowH_test2.mat')
s_hat_x_mag = permute(s_hat_x_mag_mean, [2 1 3]);
s_hat_y_mag = permute(s_hat_y_mag_mean, [2 1 3]);
%%
xslice = [0];   
yslice = 0;
zslice = 0;
%%
figure(1);

% ax1= subplot(1,2,1);
% M=200;
% N=100;
% x = 0:.8:M;
% y = 0:.8:N;
% [X,Y] = meshgrid(x,y);
% T = 0;
% Z = sin(10*pi/M*Y + 2*T);
% surf(X,Y,Z);
% xlabel('x',  'fontsize', 15)
% ylabel('y',  'fontsize', 15)
% zlabel('Z', 'fontsize', 22)
% shading interp;
% colormap(ax1, cool(20));
% title(['sin(10y\pi/200 + 2t) @ t = 0'], 'fontsize', 18)
% colorbar()

subplot(1,2,1);
slice(R,C,V,s_hat_x_mag,xslice,yslice,zslice);
xlabel('k_x',  'fontsize', 15)
ylabel('k_y',  'fontsize', 15)
zlabel('\omega', 'fontsize', 22)
title([BEDFORM ': s_x'], 'fontsize', 18)
colorbar()

subplot(1,2,2)
slice(R,C,V,s_hat_y_mag,xslice,yslice,zslice);
xlabel('k_x',  'fontsize', 15)
ylabel('k_y',  'fontsize', 15)
zlabel('\omega', 'fontsize', 22)
title([BEDFORM ': s_y'], 'fontsize', 18)
colorbar()