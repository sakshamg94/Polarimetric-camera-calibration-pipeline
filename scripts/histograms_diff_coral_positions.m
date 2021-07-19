clear
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
% for p =1: length(distances)
%     DIST = distances(p);
DIST = 0;
x = cell(4,1);
for portion_idx =1:1:4
    i=portion_idx;
    filename = ['boils_25fps_25Pump_25cmH',...
        '_QUANTITY_',QUANTITY,'_PORTION',num2str(portion_idx), '.mat'];
%     filename = ['corals','_QUANT',QUANTITY,'_DIST',num2str(DIST),'cm_PORTION',num2str(portion_idx), '.mat'];
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
% running_sum = sum(x{1,1},3);
% nums = size(x{1,1},3);
% for i =2:1:size(x,1)
%     running_sum = running_sum+sum(x{i,1},3);
%     nums = nums+ size(x{1,1},3);
% end
% mean_mat = running_sum/nums;
% for i= 1:1:size(x,1)
%     x{i,1} = x{i,1} - mean_mat;
% end
a = cat(3,x{1,1}(1:10:end,1:10:end,:), ...
    x{2,1}(1:10:end,1:10:end,:),...
    x{3,1}(1:10:end,1:10:end,:),...
    x{4,1}(1:10:end,1:10:end,:));
dat = a;
%%
close 
figure(1)
nbins = 4000;
a = reshape(dat,[],1);
[a, ptr] =  rmoutliers(a,'mean') ;
[counts,edges] = histcounts(a,nbins);
% h = histogram('BinEdges',edges,'BinCounts',counts,'Normalization','pdf');
% h.EdgeColor = 'none';
% h.FaceColor = 'blue';
% h.FaceAlpha = 0.5;%.6;
semilogy(edges(1:end-1), counts, 'r.', 'MarkerSize', 2);
xlabel("bin")
ylabel("Riemann normalized histogram")
set(gca,'yscale','log')
grid on
% title_str = [title_quant{quantity_idx},...
%     '$$^\prime = S_x(x,y) - \left<S_x\right>(x,y)$$'];
title_str = [title_quant{quantity_idx}];
title(title_str, 'interpreter','latex', 'fontsize',11)
xline(0, 'r--');
skew = skewness(a,0,'all');
% legend({sprintf("skew %.3f, nbins = %d",skew , h.NumBins)});

location = '../FLIR_Camera/histograms/';
% save_prefix = [save_quant{quantity_idx},'_',upper(BEDFORM), '_',...
%     upper(FLOW_SPEED),'flow_', upper(SUBMERGENCE), 'depth_DIST'...
%     num2str(DIST),'cm']; % toogle lines 43-52 and add _noMeanSubtraction
% save_file = [location, save_prefix,'.png'];
% saveas(gcf, save_file);
% end