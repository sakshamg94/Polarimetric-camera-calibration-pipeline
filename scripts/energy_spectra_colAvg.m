%% retrieve the time series data
clear
close all
titleStr = 'Low power jet Dist 0cm';%'High power Capped Jet Dist 0cm';

% load
% flow_idx  =2;%:3
% submergence_idx = 2;
% bed_idx = 4;
quantity_idx = 3;

quantities = {'slope_Azi_angle', 'slope_x', 'slope_y'};% to save
title_quant = {'Slope Azimuth', 'Streamwise slope', 'Spanwise slope'};
save_quant = {'Slope_azimuth', 'Streamwise_slope', 'Spanwise_slope'};
BEDFORMS = {'corals', 'canopy', 'rocks', 'dunes'};
flow_speeds = {'fast', 'med', 'slow'};
submergences = {'Deep', 'Intermed', 'Shallow'};

% FLOW_SPEED = flow_speeds{flow_idx};
% SUBMERGENCE = submergences{submergence_idx};
% BEDFORM = BEDFORMS{bed_idx};
QUANTITY = quantities{quantity_idx};

% for portion_idx =1:1:4
%     disp(portion_idx)
% %     filename = ['waterjet_powerHighCapped1_Dist0cm_QUANTITY_'...
% %         ,QUANTITY,'_PORTION',num2str(portion_idx),'.mat'];
%     filename = ['waterjet_powerHigh_Dist0cm_15fps_25cmH_QUANTITY_'...
%         ,QUANTITY,'_PORTION',num2str(portion_idx),'.mat'];
% %     filename = [BEDFORM,'_QUANT',QUANTITY,'_PORTION',...
% %         num2str(portion_idx),...
% %         '_',FLOW_SPEED,'Flow_',SUBMERGENCE,'H_test2.mat'];
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
% clearvars -except x
% x = reshape(x, size(x,1), size(x,2), size(x,3) * size(x,4)); % shape is (#rows, cols, 225*4)
% save('slope_y_Low_power_jet_Dist0cm.mat', 'x')
load('slope_x_Low_power_jet_Dist0cm.mat')
%% subtract the temporal mean from each location
data = x - mean(x,3);
% data = x;

%% get the fft to get the k-omega energy spectrum
spectra = zeros(size(data,1), size(data,2), size(data,3));
n_k = size(spectra,1);
n_omega = size(spectra, 3);
for i = 1:1:length(size(data,2))
    spectrum = fft2(reshape(data(:,i,:), ...
                    size(data(:,i,:),1), size(data(:,i,:),3)));
    spectrum = fftshift(spectrum, 1)/n_k/n_omega;
    spectra(:,i,:) = spectrum;
end

%%
L = 0.25; %[m]
kx = (-n_k/2:n_k/2-1)*2*pi/L;
kx = kx / 2/pi;
T = 60;% [seconds]
omega = (0:n_omega-1)*2*pi/T;
omega = omega/2/pi;
exx = abs(spectra).^2;
exx_mean = mean(exx, 2);

midk_id = size(exx_mean,1)/2+1;
exx_mean(midk_id,:) = 0;
exx_mean(:,1) = 0;

close all
clc
delta = 20;

figure(1)
kx_subset = kx(1,midk_id -delta:midk_id + delta);
imagesc(omega, kx_subset ,...
            log10(squeeze(exx_mean(midk_id - delta:midk_id + delta, :))));
colormap(inferno(256))
colorbar();
title({'Spectrum of $h_x$: $E^{x,x}(k_x, \omega)$', titleStr}...
    ,'interpreter','latex', 'fontsize',14)
xlabel('$\omega/2\pi$ [rad s$^{-1}$]','interpreter','latex', 'fontsize',12)
ylabel('$k/2\pi$ [m$^{-1}$]','interpreter','latex', 'fontsize',12)
%%
clc
figure(2)
kx_subset = kx(1,midk_id - delta:midk_id + delta);
imagesc(omega, kx_subset ,...
            log10(squeeze(exx_mean(midk_id - delta:midk_id + delta, :))));
colormap(inferno(256))
colorbar();
title({'Spectrum of $h_x$: $E^{x,x}(k_x, \omega)$', titleStr}...
    ,'interpreter','latex', 'fontsize',14)
xlabel('$\omega/2\pi$ [rad s$^{-1}$]','interpreter','latex', 'fontsize',12)
ylabel('$k/2\pi$ [m$^{-1}$]','interpreter','latex', 'fontsize',12)
hold on

% convection by the mean flow omegat = -k *U
U = 0.80;
plot( -U*kx_subset , kx_subset ,'b', 'LineWidth', 1.2, 'DisplayName',sprintf('$-Uk ~(U = %0.2f)$',U))
% plot(U*kx_subset , kx_subset ,'b', 'LineWidth', 1.2)

% gravity capillary wave
sigma = 7.3e-4; %[N/m]
rho = 1000; %[kg/m3]
g = 9.8; %[m/s2]
grav_capil_omega1 = (g*kx_subset + sigma / rho * kx_subset.^3).^0.5 ...
    + U*kx_subset;
grav_capil_omega2 = (g*kx_subset + sigma / rho * kx_subset.^3).^0.5 ...
    - U*kx_subset;
grav_capil_omega=  (g*kx_subset + sigma / rho * kx_subset.^3).^0.5;
plot(abs(grav_capil_omega1), kx_subset, 'c', 'LineWidth', 1.2,...
    'DisplayName','$|(gk + \sigma k^3/\rho)^{1/2} + Uk|$');
plot(abs(grav_capil_omega2), kx_subset, 'g', 'LineWidth', 1.2,...
    'DisplayName','$|(gk + \sigma k^3/\rho)^{1/2} - Uk|$');
plot(abs(grav_capil_omega), kx_subset, 'k--', 'LineWidth', 1.2,...
    'DisplayName','$|(gk + \sigma k^3/\rho)^{1/2}|$');
legend('interpreter','latex', 'fontsize',10)
%% integrate the spectrum in omega domain and get the 1D spectrum
ek = zeros(size(exx,1),size(exx,2));
for i  = 1:1:size(spectra,2)
    ek(:,i) = trapz(omega, squeeze(exx(:,i,:)), 2);
end
ek_mean = mean(ek, 2);
figure(3);
loglog(kx, ek_mean,'.-')
grid on
hold on

% get the positive k part of the spectrum and multiply energy by 2
kx_pos = kx(1,513:end);
ek_mean_pos = 2*ek_mean(513:end,1);

% select the linear part of the spectrum
ek_mean_pos = ek_mean_pos(20:40);
kx_pos = kx_pos(20:40);

% Set up fittype and options.
[xData, yData] = prepareCurveData( kx_pos, ek_mean_pos );

% Set up fittype and options.   
ft = fittype( 'power1' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
% opts.StartPoint = [1.05024234046551e-07 -0.908094525363422];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
% loglog(kx_pos, 0.65*fitresult.a*(kx_pos).^fitresult.b,'k--');
% legend('$E_x^{h_y}(k_x)$'...
%         ,sprintf('${%.2E} k^{%.2f}$',fitresult.a, fitresult.b)...
%         ,'interpreter','latex', 'fontsize',10)

title({'Wavenumber spectrum $E_x^{h_x}(k_x)$', titleStr}...
    ,'interpreter','latex', 'fontsize',14)
xlabel('$k/2\pi$ [m$^{-1}$]','interpreter','latex', 'fontsize',12)
ylabel('$E_x^{h_x}(k_x)$ [m$^3$s$^{-2}$]','interpreter','latex', 'fontsize',12)
% ylim([2e-10 1e-8])