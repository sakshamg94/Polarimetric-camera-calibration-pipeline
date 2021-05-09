% Use the POD with the wrapper:
clear;
close all;
clc
removeNan = 1;
load('ZOOMED_2DFFT_slopeAziTimeSeriesPOD_rocks_fastFlow_ShallowH_test2.mat')
I = slopeMag_hat_mag_mean;
[n,nx,ny] = size(I) ; % x is the cols, y: rows
% view the zoomed in image
lim = 100;
delta = 3;
I_zoom = I(:,nx/2 - lim/2:nx/2 + lim/2+ delta, ny/2 - lim/2:ny/2 + lim/2 +delta);
[d,mx, my] = size(I_zoom); 
center = [mx/2 , my/2];% center of the circle;
xc = center(1);
yc = center(2);
kx = -mx/2+0.5:1:mx/2-0.5;
ky = -my/2+0.5:1:my/2-0.5;
% integral = trapz(ky,trapz(kx,I_zoom,2));
% I_zoom = I_zoom/integral;
if removeNan==1
    I_zoom(:,xc,yc) = 0;
    I_zoom(:,xc,:) = 0;
    I_zoom(:,:,yc) = 0;
end
[U_POD, S_POD, V_POD] = pod(I_zoom);

%%
%Plots the mode energies
ModeEnergies=S_POD.^2;
ModeEnergyFraction=ModeEnergies/sum(ModeEnergies);

ax0 = figure(3);
ax0.Color = 'w';
bar(1:length(ModeEnergies),ModeEnergyFraction,'k');
title('Mode Energies');
%Note only the first  modes have significant energy. 
% The noise is spread out through all modes.

%%
%Plots the mode shape m for visualization purposes:
x_corner = [min(kx), max(kx)];
y_corner = [min(ky), max(ky)];
ax1 = figure(1);
ax1.Color = 'w';
for m = 1:1:12
    subplot(4,3,m);
    modeShape=squeeze(U_POD(m,:,:));
    imagesc(x_corner,y_corner,modeShape);
    hold on    
    caxis([-max(abs(modeShape(:))) max(abs(modeShape(:)))])
    colormap redblue;
    colorbar()
    set(gca,'ydir','normal')
    axis square
    shading interp;
    xlabel('$$k_x$$ centered at 0 $$px^{-1}$$', 'interpreter','latex', 'fontsize',11)
    ylabel('$$k_y$$ centered at 0 $$px^{-1}$$', 'interpreter','latex', 'fontsize',11)
    title(['Mode Shape ' num2str(m,'%0.0f')]);
end
%Note Modes 1 and 2 are a wave pair. This is because POD is a real-valued function.
%So this means that, in order to produce a propagating wave, a pair of two phase-shifted modes are required,
%similar to a sine wave - cosine wave pair.

%Since the wave equation has a linear dispersion relationship (i.e., wave speed is constant), then only modes
%1 and 2 are relevant to this problem, and they encapsulate the information of all Fourier modes.
%In fluid dynamics, where there are dispersive waves, multiple modes will appear in the modal decomposition.
displayQuantity_str = 'Integral normalized $$\left <\log^2\left |  FFT\left(\tan^{-1}\frac{S_{spanwise}}{S_{streamwise}}\right)\right |\right >$$';
flowCase_str = [upper(BEDFORM), ': ', upper(FLOW_SPEED), ' flow - ', upper(SUBMERGENCE), ' depth'];
title_string = {displayQuantity_str, ' ', flowCase_str};
%% plot the original 12 inputs
% ax2 = figure(2);
% ax2.Color = 'w';
% for m = 1:1:12
%     subplot(4,3,m);
%     modeShape=squeeze(I_zoom(m,:,:));
%     imagesc(x_corner,y_corner,modeShape);
%     hold on    
%     caxis([-max(abs(modeShape(:))) max(abs(modeShape(:)))])
%     colormap(gray(256))
%     colorbar()
%     set(gca,'ydir','normal')
%     axis square
%     shading interp;
%     xlabel('$$k_x$$ centered at 0 $$px^{-1}$$', 'interpreter','latex', 'fontsize',11)
%     ylabel('$$k_y$$ centered at 0 $$px^{-1}$$', 'interpreter','latex', 'fontsize',11)
%     title([num2str(m,'%0.0f')]);
% end
