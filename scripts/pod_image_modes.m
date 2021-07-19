% cd into the folder where the raw images are located
clear; close all;
titleStr = 'Low power jet, 0cm from ROI';
list=dir;
n = length(list) - 4;
a = imread(list(5).name);
x = zeros(n/4, size(a,1)/2, size(a,2)/2);
for i =1:1:n/4
    if endsWith(list(i).name, "tiff") == 1
        if strcmp(list(i).name(1:3), "ref")
            continue
        end
        im = imread(list(i).name);
        x(i,:,:) = im(1:2:end, 1:2:end);
    end
end
%%
%Now uses this solution to compute the POD with the wrapper:
[U_POD, S_POD, V_POD] = pod(x);

%Plots the mode energies
ModeEnergies=S_POD.^2;
ModeEnergyFraction=ModeEnergies/sum(ModeEnergies);

figure('Color','w');
bar(1:length(ModeEnergies),ModeEnergyFraction,'k');
title('Mode Energies');
%Note only the first two modes have significant energy. The 

%%
ax1 = figure(1);
ax1.Color = 'w';
for m = 1:1:12
    subplot(4,3,m);
    modeShape=squeeze(U_POD(m,:,:));
    imagesc(modeShape);
    hold on    
    caxis([-max(abs(modeShape(:))) max(abs(modeShape(:)))])
    colormap redblue;
    colorbar()
    set(gca,'ydir','normal')
    axis square
    shading interp;
%     xlabel('$$k_x$$ centered at 0 $$px^{-1}$$', 'interpreter','latex', 'fontsize',11)
%     ylabel('$$k_y$$ centered at 0 $$px^{-1}$$', 'interpreter','latex', 'fontsize',11)
    title(['Mode Shape ' num2str(m,'%0.0f')]);
end
%Note Modes 1 and 2 are a wave pair. This is because POD is a real-valued function.
%So this means that, in order to produce a propagating wave, a pair of two phase-shifted modes are required,
%similar to a sine wave - cosine wave pair.

%Since the wave equation has a linear dispersion relationship (i.e., wave speed is constant), then only modes
%1 and 2 are relevant to this problem, and they encapsulate the information of all Fourier modes.
%In fluid dynamics, where there are dispersive waves, multiple modes will appear in the modal decomposition.
sgtitle(titleStr)

%%
%Plots the time coefficient matrix V for modes 1 and 2, for visualization purposes:
TimeCoefficients1=V_POD(:,1);
TimeCoefficients2=V_POD(:,2);
TimeCoefficients3=V_POD(:,3); %For 3th mode
TimeCoefficients4=V_POD(:,4); %For 3th mode

ax2 = figure(2);
ax2.Color = 'w';
t = 1:1:n/4;
freq = 1/3;
t = t.*freq;
plot(t,TimeCoefficients1,'m-'); hold on;
plot(t,TimeCoefficients2,'b-');
plot(t,TimeCoefficients3,'r-');
plot(t,TimeCoefficients4,'k-');


legend('Mode 1','Mode 2','Mode 3','Mode 4');
title({'Time Coefficients from POD V matrix', titleStr})
