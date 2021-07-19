%% Solution for planar sine wave
% clear
% close all; clc;
% titleStr= 'Monochromatic sine wave';
% L = 0.25;
% x = 0:4:1024;
% y = 0:4:1024;
% [X,Y] = meshgrid(x,y);
% k0 = 1/8;
% A = 0.01;
% b = 0;%1/20;
% omega = 5;
% times = 0:1:900-1;
% %
% %Now puts this solution inside a 3D matrix 
% Vfield_Snapshots = zeros(length(times),size(X,1),size(X,2));
% Vxgradfield_Snapshots = zeros(length(times),size(X,1),size(X,2));
% for i =1:length(times)
%     t = times(i);
%     F  = A * exp(-b*t) * sin(k0 * X + omega * t);
%     dFx = A * exp(-b*t) * k0 * cos(k0 * X + omega * t);
%     Vfield_Snapshots(i,:,:) = F;
%     Vxgradfield_Snapshots(i,:,:) = dFx;
% end
% x = permute(Vxgradfield_Snapshots, [3,2,1]);
% x = reshape(x, size(x,1), size(x,2), size(x,3) * size(x,4)); % shape is (#rows, cols, 225*4)
%% Solution for radially propagating ripples
clear
close all; clc;
titleStr= 'Circular ripples (radially moving sine wave)';

L = 0.25;
x = 0:4:1023;
y = 0:4:1023;
[X,Y] = meshgrid(x,y);
[nRows, nCols] = size(X);
xmid = x(round(nCols/2));
ymid = y(round(nRows/2));
R = ((X - xmid).^2  + (Y - ymid).^2).^0.5;
kr = 1/8;
A = 0.01;
b = 0;%1/20;
omega = 5;
times = 0:1:900-1;
%
%Now puts this solution inside a 3D matrix 
Vfield_Snapshots = zeros(length(times),size(X,1),size(X,2));
Vxgradfield_Snapshots = zeros(length(times),size(X,1),size(X,2));
Vygradfield_Snapshots = zeros(length(times),size(X,1),size(X,2));

for i =1:length(times)
    t = times(i);
    F  = A * sin(kr * R + omega * t) * exp(-b*t) ;
    dFx = A *kr* exp(-b*t) * cos(kr * R + omega * t) ./ R .*(X - xmid);
    dFy = A *kr* exp(-b*t) * cos(kr * R + omega * t) ./ R .*(Y - ymid);
    Vfield_Snapshots(i,:,:) = F;
    Vxgradfield_Snapshots(i,:,:) = dFx;
    Vygradfield_Snapshots(i,:,:) = dFy;
end
x = permute(Vygradfield_Snapshots, [3,2,1]);
x = reshape(x, size(x,1), size(x,2), size(x,3) * size(x,4)); % shape is (#rows, cols, 225*4)
%% Row averaging type spectra (transverse: Exy, Eyy)

data = x - mean(x,3);

% get the fft to get the k-omega energy spectrum
spectra = zeros(size(data,1), size(data,2), size(data,3));
n_k = size(spectra,2);
n_omega = size(spectra, 3);
for i = 1:1:length(size(data,1))
    spectrum = fft2(squeeze(data(i,:,:)));
    spectrum = fftshift(spectrum, 1)/n_k/n_omega;
    spectra(i,:,:) = spectrum;
end
%
ky = (-n_k/2:n_k/2-1)*2*pi/L;
ky = ky / 2/pi;
T = 60;% [seconds]
omega = (0:n_omega-1)*2*pi/T;
omega = omega/2/pi;
exy = abs(spectra).^2;
exy_mean = squeeze(mean(exy, 1));

midk_id = round(size(exy_mean,1)/2)+1;
exy_mean(midk_id,:) = 0;
exy_mean(:,1) = 0;

close all
clc
delta = 100;

figure(1)
ky_subset = ky(1,midk_id -delta:midk_id + delta);
imagesc(omega, ky_subset ,...
            log10(exy_mean(midk_id - delta:midk_id + delta, :)));
colormap(inferno(256))
colorbar();
title({'Transverse spectrum of $h_y$: $E^{y,y}(k_y, \omega)$', titleStr}...
    ,'interpreter','latex', 'fontsize',14)
xlabel('$\omega/2\pi$ [rad s$^{-1}$]','interpreter','latex', 'fontsize',12)
ylabel('$k/2\pi$ [m$^{-1}$]','interpreter','latex', 'fontsize',12)

% integrate the spectrum in omega domain and get the 1D spectrum
ek = zeros(size(exy,1),size(exy,2));
for i  = 1:1:size(spectra,1)
    ek(i,:) = trapz(omega, squeeze(exy(i,:,:)), 2)';
end
ek_mean = mean(ek, 1);

figure(3);
subplot(1,2,1)
loglog(ky, ek_mean,'.-')
grid on
hold on

% get the positive k part of the spectrum and multiply energy by 2
ky_pos1 = ky(1,round(length(ky)/2)+1:end);
ek_mean_pos1 = 2*ek_mean(1,round(length(ky)/2)+1:end);

% select the linear part of the spectrum
ek_mean_pos = ek_mean_pos1(8:40);
ky_pos = ky_pos1(8:40);

% Set up fittype and options.
[xData, yData] = prepareCurveData( ky_pos, ek_mean_pos );

% Set up fittype and options.
ft = fittype( 'power1' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
% opts.StartPoint = [1.05024234046551e-07 -0.908094525363422];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
% loglog(ky_pos, 0.6*fitresult.a*(ky_pos).^fitresult.b,'k--');
% legend('$E^{h_x}(k_y)$'...
%         ,sprintf('${%.2E} k^{%.2f}$',fitresult.a, fitresult.b)...
%         ,'interpreter','latex', 'fontsize',10)

title({'Wavenumber spectrum $E^{h_y}(k_y)$', titleStr}...
    ,'interpreter','latex', 'fontsize',14)
xlabel('$k/2\pi$ [m$^{-1}$]','interpreter','latex', 'fontsize',12)
ylabel('$E^{h_y}(k_y)$ [m$^3$s$^{-2}$]','interpreter','latex', 'fontsize',14)
% ylim([1e-10 1e-7])

subplot(1,2,2)
plot(ky_pos1(2:end), diff(log(ek_mean_pos1))./diff(log(ky_pos1)), 'k.-')
title({'Slope of logarithmic spectrum', titleStr}...
    ,'interpreter','latex', 'fontsize',14)
xlabel('$k/2\pi$ [m$^{-1}$]','interpreter','latex', 'fontsize',12)
ylabel('$\frac{d\log E}{d\log k_y}$','interpreter','latex', 'fontsize',16)
grid on

set(gcf, 'Position', [232 283 920.5000 420])


%% Col averaging type spectra (transverse: Exx)
T = 60;
L = 0.25;
delta = 100;

data = x - mean(x,3);

% get the fft to get the k-omega energy spectrum
spectra = zeros(size(data,1), size(data,2), size(data,3));
n_k = size(spectra,1);
n_omega = size(spectra, 3);
for i = 1:1:length(size(data,2))
    spectrum = fft2(reshape(data(:,i,:), ...
                    size(data(:,i,:),1), size(data(:,i,:),3)));
    spectrum = fftshift(spectrum, 1)/n_k/n_omega;
    spectra(:,i,:) = spectrum;
end

%
kx = (-n_k/2:n_k/2-1)*2*pi/L;
kx = kx / 2/pi;
omega = (0:n_omega-1)*2*pi/T;
omega = omega/2/pi;
exx = abs(spectra).^2;
exx_mean = mean(exx, 2);

midk_id = round(size(exx_mean,1)/2)+1;
exx_mean(midk_id,:) = 0;
exx_mean(:,1) = 0;

close all
clc

figure(1)
kx_subset = kx(1,midk_id -delta:midk_id + delta);
imagesc(omega, kx_subset ,...
            log10(squeeze(exx_mean(midk_id - delta:midk_id + delta, :))));
colormap(inferno(256))
colorbar();
title({'Longtitudinal spectrum of $h_y$: $E^{y,x}(k_x, \omega)$', titleStr}...
    ,'interpreter','latex', 'fontsize',14)
xlabel('$\omega/2\pi$ [rad s$^{-1}$]','interpreter','latex', 'fontsize',12)
ylabel('$k/2\pi$ [m$^{-1}$]','interpreter','latex', 'fontsize',12)

% integrate the spectrum in omega domain and get the 1D spectrum
ek = zeros(size(exx,1),size(exx,2));
for i  = 1:1:size(spectra,2)
    ek(:,i) = trapz(omega, squeeze(exx(:,i,:)), 2);
end
ek_mean = mean(ek, 2);
figure(3);
subplot(1,2,1)
loglog(kx, ek_mean,'.-')
grid on
hold on

% get the positive k part of the spectrum and multiply energy by 2
kx_pos1 = kx(1,round(length(kx)/2)+1:end);
ek_mean_pos1 = 2*ek_mean(round(length(kx)/2)+1:end,1);

% select the linear part of the spectrum
ek_mean_pos = ek_mean_pos1(10:40);
kx_pos = kx_pos1(10:40);

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

title({'Wavenumber spectrum $E_x^{h_y}(k_x)$', titleStr}...
    ,'interpreter','latex', 'fontsize',14)
xlabel('$k/2\pi$ [m$^{-1}$]','interpreter','latex', 'fontsize',12)
ylabel('$E_x^{h_y}(k_x)$ [m$^3$s$^{-2}$]','interpreter','latex', 'fontsize',12)
% ylim([2e-10 1e-8])

subplot(1,2,2)
plot(kx_pos1(1,2:end), diff(log(ek_mean_pos1))./diff(log(kx_pos1))', 'k.-')
title({'Slope of logarithmic spectrum', titleStr}...
    ,'interpreter','latex', 'fontsize',14)
xlabel('$k/2\pi$ [m$^{-1}$]','interpreter','latex', 'fontsize',12)
ylabel('$\frac{d\log E}{d\log k_x}$','interpreter','latex', 'fontsize',16)
grid on

set(gcf, 'Position', [232 283 920.5000 420])