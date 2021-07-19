%% retrieve the time series data
clear
close all
titleStr = 'High power Capped Jet Dist 0cm';%'High power jet Dist 28cm';

% load
% flow_idx  =2;%:3
% submergence_idx = 2;
% bed_idx = 4;
quantity_idx = 2;

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

for portion_idx =1:1:4
    disp(portion_idx)
    filename = ['waterjet_powerHighCapped1_Dist0cm_QUANTITY_'...
        ,QUANTITY,'_PORTION',num2str(portion_idx),'.mat'];
%     filename = ['waterjet_powerHigh_Dist28cm_15fps_25cmH_QUANTITY_'...
%         ,QUANTITY,'_PORTION',num2str(portion_idx),'.mat'];
%     filename = [BEDFORM,'_QUANT',QUANTITY,'_PORTION',...
%         num2str(portion_idx),...
%         '_',FLOW_SPEED,'Flow_',SUBMERGENCE,'H_test2.mat'];
    load(filename)
    if strcmp(QUANTITY,'slope_x')
        A = slope_x;
        clear slope_x
    elseif strcmp(QUANTITY,'slope_y')
        A = slope_y;
        clear slope_y
    end
    [rows, cols, times] = size(A);
    r =1:10:rows;
    if portion_idx == 1
        x = zeros(length(r), cols, times, 4);
    end
    for i =1:length(r)
        x(i,:,:,portion_idx) = A(r(1,i),:,:);
    end
end
%%
% clearvars -except x
x = reshape(x, size(x,1), size(x,2), size(x,3) * size(x,4)); % shape is (#rows, cols, 225*4)
% save('slope_x_iny_High_power_jet_Dist28cm.mat', 'x')
%% subtract the temporal mean from each location
data = x - mean(x,3);
% data = x;

%% get the fft to get the k-omega energy spectrum
spectra = zeros(size(data,1), size(data,2), size(data,3));
n_k = size(spectra,2);
n_omega = size(spectra, 3);
for i = 1:1:length(size(data,1))
    spectrum = fft2(squeeze(data(i,:,:)));
    spectrum = fftshift(spectrum, 1)/n_k/n_omega;
    spectra(i,:,:) = spectrum;
end

%%
L = 0.25; %[m]
ky = (-n_k/2:n_k/2-1)*2*pi/L;
ky = ky / 2/pi;
T = 60;% [seconds]
omega = (0:n_omega-1)*2*pi/T;
omega = omega/2/pi;
exy = abs(spectra).^2;
exy_mean = squeeze(mean(exy, 1));

midk_id = size(exy_mean,1)/2+1;
exy_mean(midk_id,:) = 0;
exy_mean(:,1) = 0;

close all
clc
delta = 400;

figure(1)
ky_subset = ky(1,midk_id -delta:midk_id + delta);
imagesc(omega, ky_subset ,...
            log10(exy_mean(midk_id - delta:midk_id + delta, :)));
colormap(inferno(256))
colorbar();
title({'Transverse spectrum of $h_x$: $E_{xy}(k_y, \omega)$', titleStr}...
    ,'interpreter','latex', 'fontsize',14)
xlabel('$\omega/2\pi$ [rad s$^{-1}$]','interpreter','latex', 'fontsize',12)
ylabel('$k/2\pi$ [m$^{-1}$]','interpreter','latex', 'fontsize',12)
%%
% clc
% figure(2)
% ky_subset = ky(1,midk_id - delta:midk_id + delta);
% imagesc(omega, ky_subset ,...
%             log10(squeeze(exy_mean(midk_id - delta:midk_id + delta, :))));
% colormap(inferno(256))
% colorbar();
% title({'Longtitudinal spectrum of $h_y$: $E_{xx}(k_x, \omega)$', titleStr}...
%     ,'interpreter','latex', 'fontsize',14)
% xlabel('$\omega/2\pi$ [rad s$^{-1}$]','interpreter','latex', 'fontsize',12)
% ylabel('$k/2\pi$ [m$^{-1}$]','interpreter','latex', 'fontsize',12)
% hold on
% 
% % convection by the mean flow omegat = -k *U
% U = 0.45;
% plot(ky_subset , U*ky_subset , 'b', 'LineWidth', 1.2)
% plot(ky_subset , -U*ky_subset , 'b', 'LineWidth', 1.2)
% 
% % gravity capillary wave
% sigma = 7.3e-4; %[N/m]
% rho = 1000; %[kg/m3]
% g = 9.8; %[m/s2]
% grav_capil_omega1 = (g*ky_subset + sigma / rho * ky_subset.^3).^0.5 ...
%     + U*ky_subset;
% grav_capil_omega2 = (g*ky_subset + sigma / rho * ky_subset.^3).^0.5 ...
%     - U*ky_subset;
% plot(abs(grav_capil_omega1), ky_subset, 'g', 'LineWidth', 1.2);
% plot(abs(grav_capil_omega2), ky_subset, 'c', 'LineWidth', 1.2);
% 
% legend('$+Uk$','$-Uk$','$(gk + \sigma k^3/\rho)^{1/2} + Uk$',...
%     '$(gk + \sigma k^3/\rho)^{1/2} - Uk$',...
%     'interpreter','latex', 'fontsize',10)
%% integrate the spectrum in omega domain and get the 1D spectrum
ek = zeros(size(exy,1),size(exy,2));
for i  = 1:1:size(spectra,1)
    ek(i,:) = trapz(omega, squeeze(exy(i,:,:)), 2)';
end
ek_mean = mean(ek, 1);
figure(3);
loglog(ky, ek_mean,'.-')
grid on
hold on

% get the positive k part of the spectrum and multiply energy by 2
ky_pos = ky(1,613:end);
ek_mean_pos = 2*ek_mean(1,613:end);

% select the linear part of the spectrum
ek_mean_pos = ek_mean_pos(8:20);
ky_pos = ky_pos(8:20);

% Set up fittype and options.
[xData, yData] = prepareCurveData( ky_pos, ek_mean_pos );

% Set up fittype and options.
ft = fittype( 'power1' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
% opts.StartPoint = [1.05024234046551e-07 -0.908094525363422];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
loglog(ky_pos, 0.6*fitresult.a*(ky_pos).^fitresult.b,'k--');
legend('$E_y^{h_y}(k_y)$'...
        ,sprintf('${%.2E} k^{%.2f}$',fitresult.a, fitresult.b)...
        ,'interpreter','latex', 'fontsize',10)

title({'Wavenumber spectrum $E_y^{h_x}(k_y)$', titleStr}...
    ,'interpreter','latex', 'fontsize',14)
xlabel('$k/2\pi$ [m$^{-1}$]','interpreter','latex', 'fontsize',12)
ylabel('$E_y^{h_x}(k_y)$ [m$^3$s$^{-2}$]','interpreter','latex', 'fontsize',12)
ylim([1e-10 1e-7])