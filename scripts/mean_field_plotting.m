clear
a = [];
close all
flow_idx  = 1;
submergence_idx = 3;
bed_idx = 1;
quantity_idx = 3;

quantities = {'slope_Azi_angle', 'slope_x', 'slope_y'};% to save
title_quant = {'Slope Azimuth', 'Streamwise slope', 'Spanwise slope'};
save_quant = {'Slope_azimuth', 'Streamwise_slope', 'Spanwise_slope'};
BEDFORMS = {'corals', 'canopy', 'rocks', 'dunes'};
flow_speeds = {'fast', 'med', 'slow'};
submergences = {'Deep', 'Intermed', 'Shallow'};

FLOW_SPEED = flow_speeds{flow_idx};
SUBMERGENCE = submergences{submergence_idx};
BEDFORM = BEDFORMS{bed_idx};
QUANTITY = quantities{quantity_idx};
distances = [22, -50, -125, 172, 247];
DIST = 0;
% for p =5%1: length(distances)
%     DIST = distances(p);
x = cell(4,1);
for portion_idx =1:1:4
    i=portion_idx;
%     filename = ['corals','_QUANT',QUANTITY,'_DIST',num2str(DIST),...
%         'cm_PORTION',num2str(portion_idx), '.mat'];
    filename = ['boils_25fps_25Pump_25cmH',...
        '_QUANTITY_',QUANTITY,'_PORTION',num2str(portion_idx), '.mat'];
%         filename = [BEDFORM,'_QUANT',QUANTITY,'_PORTION',...
%             num2str(portion_idx),...
%             '_',FLOW_SPEED,'Flow_',SUBMERGENCE,'H_test2.mat'];
    load(filename)
    if strcmp(QUANTITY,'slope_Azi_angle')
        x{i,1} = slope_Azi_angle;
        clear slope_Azi_angle
    elseif strcmp(QUANTITY,'slope_x')
        x{i,1} = slope_x;
        clear slope_x
    else
        x{i,1} = slope_y;
        clear slope_y
    end
end
%%
running_sum = sum(x{1,1},3);
nums = size(x{1,1},3);
for i =2:1:size(x,1)
    running_sum = running_sum+sum(x{i,1},3);
    nums = nums+ size(x{1,1},3);
end
mean_mat = running_sum/nums;
%%
close 
figure(1)
x = 2:1:size(mean_mat,2);
y = 2:1:size(mean_mat,1);
[X,Y] = meshgrid(x,y);
d = 1;
Z = mean_mat(2:d:end,2:d:end);
s = surf(X(1:d:end,1:d:end),Y(1:d:end,1:d:end),Z);
view(2);
hold on    
s.EdgeColor= 'none';
% caxis([-max(max(abs(Z))) max(max(abs(Z)))])
caxis([-0.2 0.2])
colormap redblue;
colorbar();
ax = gca;
xlim([0 1224]);
ylim([0 1024]);
ax.YDir = 'reverse';
set(gcf,'color','w');
xlabel("spanwise (y)")
ylabel("streamwise (x)")
% set(gca,'yscale','log')
% grid on
title_str = ['Temporal mean: ',title_quant{quantity_idx}];
title(title_str)

location = '../FLIR_Camera/jet_boils_plots/';
% save_prefix = [save_quant{quantity_idx},'_',upper(BEDFORM), '_',...
%     upper(FLOW_SPEED),'flow_', upper(SUBMERGENCE), 'depth_DIST'...
%     num2str(DIST),'cm'];
% save_file = [location, save_prefix,'.png'];
% saveas(gcf, save_file);
% end