%% retrieve the time series data
clear
close all
titleStr = 'Low power jet Dist 28cm';%'High power jet Dist 28cm';

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
%     filename = ['waterjet_powerHighCapped1_Dist0cm_QUANTITY_'...
%         ,QUANTITY,'_PORTION',num2str(portion_idx),'.mat'];
    filename = ['waterjet_powerLow_Dist28cm_15fps_25cmH_QUANTITY_'...
        ,QUANTITY,'_PORTION',num2str(portion_idx),'.mat'];
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

% clearvars -except x
x = reshape(x, size(x,1), size(x,2), size(x,3) * size(x,4)); % shape is (#rows, cols, 225*4)
save('slope_x_iny_Low_power_jet_Dist28cm.mat', 'x')

%% subtract the temporal mean from each location
load('slope_x_iny_Low_power_jet_Dist28cm.mat')
x2 = x;
load('slope_x_Low_power_jet_Dist28cm.mat')
x1 = x;
data1 = x1 - mean(x1, 3); % temporal mean subtraction
data2 = x2 - mean(x2, 3); % temporal mean subtraction

%% Same time auto-cross correlation in space
% to plot the Longitudinal/Transverse correlation  function
nLags = 200;
times = size(data1,3);
nCols = size(data1,2);
[temp1, lag, ~] = crosscorr(data1(:,1,1),data1(:,1,1),'NumLags',nLags);
xcfLong = zeros(size(temp1,1),nCols,times);
for i = 1:1:times
    for j =1:1:nCols
        [xcfLong(:,j,i), ~,~] = crosscorr(data1(:,j,i), data1(:,j,i),'NumLags',nLags);
    end
end

%%
nRows = size(data2,1);
[temp2, ~, ~] = crosscorr(data2(1,:,1),data2(1,:,1),'NumLags',nLags);
xcfTrans = zeros(nRows,size(temp2,2),times);
for i = 1:1:times
    for j =1:1:nRows
        [xcfTrans(j,:,i), ~,~] = crosscorr(data2(j,:,i), data2(j,:,i),'NumLags',nLags);
    end
end
%%
mid = nLags+2;
correlLong = mean(xcfLong, [2,3]);
correlLong = fftshift(correlLong);
correlLong =  correlLong(end:-1:mid);
correlTrans = mean(xcfTrans, [1,3]);
correlTrans = fftshift(correlTrans);
correlTrans =  correlTrans(end:-1:mid);

%%
Lx = 0.25;
fsx  = Lx/nLags;
rx = (1:nLags)*fsx;
Ly = 0.25;
fsy  = Ly/nLags;
ry = (1:nLags)*fsy;
%%
figure(2);

plot(rx, correlLong, '.-b');
hold on
plot(ry, correlTrans, '.-r');
hline = refline(0,0);
hline.LineStyle = '--';
hline.Color = 'k';
grid on;
title({'Longitudinal \& transverse correlations', titleStr}...
    ,'interpreter','latex', 'fontsize',14)
legend('Longitudinal: $C_{xx}(r_x)$'...
    ,'Transverse: $C_{xx}(r_y)$'...
    ,'interpreter','latex', 'fontsize',10)
xlabel('$r$ [m]','interpreter','latex', 'fontsize',12)
ylabel('$C_{\alpha \alpha}(r_\beta)$ ','interpreter','latex', 'fontsize',12)