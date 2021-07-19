clear
a = [];
close all
flow_idx  = 1;
submergence_idx = 3;
bed_idx = 1;

quantities = {'slope_Azi_angle', 'slope_x', 'slope_y'};% to save
title_quant = {'Slope Azimuth', 'Streamwise slope', 'Spanwise slope'};
save_quant = {'Slope_azimuth', 'Streamwise_slope', 'Spanwise_slope'};
BEDFORMS = {'corals', 'canopy', 'rocks', 'dunes'};
flow_speeds = {'fast', 'med', 'slow'};
submergences = {'Deep', 'Intermed', 'Shallow'};

FLOW_SPEED = flow_speeds{flow_idx};
SUBMERGENCE = submergences{submergence_idx};
BEDFORM = BEDFORMS{bed_idx};
distances = [22, -50, -125, 172, 247];
DIST = 0;

portion_idx = 1;
x = cell(3,1);
for quantity_idx =1:1:3
    QUANTITY = quantities{quantity_idx};
    filename = ['boils_25fps_25Pump_25cmH',...
        '_QUANTITY_',QUANTITY,'_PORTION',num2str(portion_idx), '.mat'];
    load(filename)
    if strcmp(QUANTITY,'slope_Azi_angle')
        x{quantity_idx,1} = slope_Azi_angle;
        clear slope_Azi_angle
    elseif strcmp(QUANTITY,'slope_x')
        x{quantity_idx,1} = slope_x;
        clear slope_x
    else
        x{quantity_idx,1} = slope_y;
        clear slope_y
    end
end

%% 

for i =1:1:225
    figure(1)
    for quantity_idx = 2:3
        subplot(1,2,quantity_idx-1)
        img = medfilt2(x{quantity_idx,1}(:,:,i));
        imagesc(img)
        hold on
        caxis([-0.1 0.1])
        colormap(flipud(inferno(256)))
        colorbar()
        axis square
        QUANTITY = quantities{quantity_idx};
        title_str = [title_quant{quantity_idx}];
        title(title_str)
    end
end
set(gcf,'Position',[100 400 1000 400])