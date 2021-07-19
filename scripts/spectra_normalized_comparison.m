%% retrieve the spectral data (mean norm)
clear
clc
close all
flow = 'med';
depth = 'shallow';
figure_filename = ['FLIR_Camera/spectra_normalized/',...
    'spectra_ratio_conparison_',flow,'_', depth,'.png'];


filename = ['slope_x_dunes_',flow,'_', depth,'.mat'];
load(filename, "meanNormalizedSpectra")
meanNormalizedSpectra_dunes = meanNormalizedSpectra;

filename = ['slope_x_rocks_',flow,'_', depth,'.mat'];
load(filename,"meanNormalizedSpectra")
meanNormalizedSpectra_rocks = meanNormalizedSpectra;

filename = ['slope_x_corals_',flow,'_', depth,'.mat'];
load(filename,"meanNormalizedSpectra")
meanNormalizedSpectra_corals = meanNormalizedSpectra;

filename = ['slope_x_canopy_',flow,'_', depth,'.mat'];
load(filename, "kx", "meanNormalizedSpectra")
meanNormalizedSpectra_canopy = meanNormalizedSpectra;

%% plot the ratios
tiledlayout(1,3)

ax1 = nexttile;
loglog(kx, meanNormalizedSpectra_dunes./meanNormalizedSpectra_canopy,'-')
grid on
title({'Normalized Spectrum Ratio', sprintf('Dunes/Canopy: %s %s',flow, depth)})
xlabel('$k/2\pi$ [m$^{-1}$]', 'fontsize',12)

ax2 = nexttile;
loglog(kx, meanNormalizedSpectra_rocks./meanNormalizedSpectra_canopy,'-')
grid on
title({'Normalized Spectrum Ratio', sprintf('Rocks/Canopy: %s %s',flow, depth)})
xlabel('$k/2\pi$ [m$^{-1}$]', 'fontsize',12)

ax3 = nexttile;
loglog(kx, meanNormalizedSpectra_corals./meanNormalizedSpectra_canopy,'-')
grid on
title({'Normalized Spectrum Ratio', sprintf('Corals/Canopy: %s %s',flow, depth)})
xlabel('$k/2\pi$ [m$^{-1}$]', 'fontsize',12)

linkaxes([ax1,ax2,ax3],'xy')
set(gcf, 'Position', [64.5000 390 1.2795e+03 420])

saveas(gcf, figure_filename);


