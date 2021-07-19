%% retrieve the time series data
clear
clc
close all
titleStr = 'Canopy Fast Shallow';%'High power Capped Jet Dist 0cm';High power jet Dist 28cm
data_filename = 'slope_x_canopy_fast_shallow.mat';
figure_filename = ['FLIR_Camera/spectra_normalized/', ...
    strrep(titleStr,' ','_'), '.png'];
quantity_idx = 2;
bed_idx = 2;


flow_idx  =1;%:3
submergence_idx = 2;

quantities = {'slope_Azi_angle', 'slope_x', 'slope_y'};% to save
% title_quant = {'Slope Azimuth', 'Streamwise slope', 'Spanwise slope'};
% save_quant = {'Slope_azimuth', 'Streamwise_slope', 'Spanwise_slope'};
% BEDFORMS = {'corals', 'canopy', 'rocks', 'dunes'};
% flow_speeds = {'fast', 'med', 'slow'};
% submergences = {'Deep', 'Intermed', 'Shallow'};
% 
% FLOW_SPEED = flow_speeds{flow_idx};
% SUBMERGENCE = submergences{submergence_idx};
% BEDFORM = BEDFORMS{bed_idx};
% QUANTITY = quantities{quantity_idx};
% 
% for portion_idx =1:1:4
%     disp(portion_idx)
% %     filename = ['waterjet_powerHighCapped1_Dist0cm_QUANTITY_'...
% %         ,QUANTITY,'_PORTION',num2str(portion_idx),'.mat'];
% %     filename = ['waterjet_powerHigh_Dist0cm_15fps_25cmH_QUANTITY_'...
% %         ,QUANTITY,'_PORTION',num2str(portion_idx),'.mat'];
%     filename = [BEDFORM,'_QUANT',QUANTITY,'_PORTION',...
%         num2str(portion_idx),...
%         '_',FLOW_SPEED,'Flow_',SUBMERGENCE,'H_test2.mat'];
%     load(filename)
%     if strcmp(QUANTITY,'slope_x')
%         A = slope_x;
%         clear slope_x
%     elseif strcmp(QUANTITY,'slope_y')
%         A = slope_y;
%         clear slope_y
%     end
%     [rows, cols, times] = size(A);
%     c =1:10:cols;
%     if portion_idx == 1
%         x = zeros(rows, length(c), times, 4);
%     end
%     for i =1:length(c)
%         x(:,i,:,portion_idx) = A(:,c(1,i),:);
%     end
% end
%%
% clear A
% x = reshape(x, size(x,1), size(x,2), size(x,3) * size(x,4)); % shape is (#rows, cols, 225*4)
% save(data_filename, 'x')
load(data_filename) % 'slope_x_High_power_jet_Dist28cm.mat'
%% subtract the temporal mean from each location
data = x - mean(x,3);
% data = x;
clear x

%% get the fft to get the k-omega energy spectrum
spectra = zeros(size(data,1), size(data,2), size(data,3));
n_k = size(spectra,1);
n_omega = size(spectra, 3);
for i = 1:1:length(size(data,2))
    spectrum = fft2(reshape(data(:,i,:), ...
                    size(data(:,i,:),1), size(data(:,i,:),3)));
    spectrum = fftshift(spectrum, 1);% /n_k/n_omega
    spectra(:,i,:) = spectrum;
end

%% integrate the spectrum in omega domain and get the 1D spectrum

L = 0.25; %[m]
kx = (-n_k/2:n_k/2-1)*2*pi/L;
kx = kx / 2/pi;
T = 60;% [seconds]
omega = (0:n_omega-1)*2*pi/T;
omega = omega/2/pi;
exx = abs(spectra).^2;

ek_integrateOmega = zeros(size(exx,1),size(exx,2));
for i  = 1:1:size(spectra,2)
    ek_integrateOmega(:,i) = trapz(omega, squeeze(exx(:,i,:)), 2);
end
ek_integrateOmega_mean_y = mean(ek_integrateOmega, 2);
ek_mean = ek_integrateOmega_mean_y/(omega(end) - omega(1));
figure(1);
loglog(kx, ek_mean, '.-')
title({'Average (in y and t) $E(k_x)$ spectrum', titleStr})
xlabel('$k/2\pi$ [m$^{-1}$]', 'fontsize',12)
ylabel('$E(k_x)$', 'fontsize',12)
grid on
%% get the normalized spectra for each snapshot
tic
allSnapshotSpectra2 = abs(fftshift(fft(data),1)).^2;
allSnapshotSpectra3 = allSnapshotSpectra2./ek_mean;
% allSnapshotSpectra2 = mean(allSnapshotSpectra2,3);
toc
%% plot the various spectra
close all
set(0,'defaultTextInterpreter','latex'); %trying to set the default

figure(2);
tiledlayout(1,4)
% take a single line in y direction to enable plotting
c = round(size(allSnapshotSpectra2,2)/2);
ax1 = nexttile;
loglog(kx, ek_mean, '-')
title({'Average (in y and t) $E(k_x)$ spectrum', titleStr})
xlabel('$k/2\pi$ [m$^{-1}$]', 'fontsize',12)
ylabel('$<E(k_x)>_{\omega; y}$', 'fontsize',14)
grid on

ax2 = nexttile;
loglog(kx, squeeze(mean(allSnapshotSpectra2(:,:, :), [2,3])), '-')
title({'Spectrum of the middle slice', ' @ t = 60s'})
xlabel('$k/2\pi$ [m$^{-1}$]', 'fontsize',12)
ylabel('$E(k)$', 'fontsize',14)
grid on

ax3 = nexttile;
loglog(kx, squeeze(allSnapshotSpectra3(:,c, end)), '-');
title({'Normalized spectrum of the middle slice', ' @ t = 60s'})
xlabel('$k/2\pi$ [m$^{-1}$]', 'fontsize',12)
ylabel('$E^*(k)$', 'fontsize',14)
grid on

ax4 = nexttile;
plot(kx, squeeze(allSnapshotSpectra3(:,c,end) - 1)*100, '-');
title({'Percent change w.r.t. average spectrum', ' @ t = 60s'})
xlabel('$k/2\pi$ [m$^{-1}$]', 'fontsize',12)
ylabel('\% change in $E(k)$', 'fontsize',14)
grid on

linkaxes([ax1, ax2, ax3], 'xy')
set(gcf, 'Position', [1 1 1368 842])
% meanColNormSpectrum = mean(squeeze(allSnapshotSpectra2(:,c,:)),2);
% loglog(kx, meanColNormSpectrum)
% plot(kx, abs(squeeze(allSnapshotSpectra2(:,c,1)) - meanColNormSpectrum)./meanColNormSpectrum, '-');

% grid on
% title({'Normalized spectrum $E^{x,x}(k_x)$: independent frames',titleStr})
% xlabel('$k/2\pi$ [m$^{-1}$]', 'fontsize',12)
% ylabel('$E(k)$', 'fontsize',12)

% set(gcf, 'Position', [3 390 1233 420])
% saveas(gcf, figure_filename);

% save(data_filename, 'kx','meanNormalizedSpectra', '-append')
