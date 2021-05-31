%% plot the pdf from the entire time series data
% load
data =[];
for flow_idx  =1%:3
    for submergence_idx = 3
        for bed_idx = 1
            for quantity_idx = 2
                try
                    x = {};
                    clear data
                    close all

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


                    x = cell(4,1);
                    for portion_idx =1:1:4
                        i=portion_idx;
                        filename = [BEDFORM,'_QUANT',QUANTITY,'_PORTION',...
                            num2str(portion_idx),...
                            '_',FLOW_SPEED,'Flow_',SUBMERGENCE,'H_test2.mat'];
                        load(filename)
                        if strcmp(QUANTITY,'slope_Azi_angle')
                            A = slope_Azi_angle;
                            clear slope_Azi_angle
                        elseif strcmp(QUANTITY,'slope_x')
                            A = slope_x;
                            clear slope_x
                        else
                            A = slope_y;
                            clear slope_y
                        end
                        rng(41);
                        [rows, cols, times] = size(A);
                        r = 1:round(rows/75):rows;%randperm(rows, 75);
                        c = 1:round(cols/75):cols;%randperm(cols, 75);
                        % for mean of 75*75~ 5600 locations
                        
                        x{i,1} = zeros(times, length(r) *  length(c));
                        counter= 1;
                        for p =1:1:length(r)
                            for q =1:1:length(c)
                                x{i,1}(:,counter) = A(p,q,:);
                                counter = counter+1;
                            end
                        end
                    end
                    %%
                    data = cat(1,x{1,1},x{2,1},x{3,1},x{4,1});
                    % Now subtract the temporal mean from each location
                    %%
                    figure(1)
                    fs = 3;
%                     [pxx, f] = pwelch(data, [],[],[], fs);
                    [pxx, f] = pwelch(data, 76,75,50, fs);
                    close all
                    figure(1);
                    for i =1:10:size(pxx,2)
                        loglog(f, pxx(:,i),'k.','MarkerSize',0.25)
                        hold on
                    end
                    loglog(f, mean(pxx,2), 'b.','MarkerSize',10)
                    xlabel('Frequency (Hz)')
                    ylabel('Power spectrum []')
                    grid on
                    title_str = [title_quant{quantity_idx},': ',...
                                upper(BEDFORM),' ',FLOW_SPEED,'-Flow ',SUBMERGENCE,' H']
                    title(title_str)              

                    location = '../FLIR_Camera/power_spectral_densities/';
                    save_prefix = [save_quant{quantity_idx},'_',upper(BEDFORM), '_',...
                                    upper(FLOW_SPEED),'flow_', upper(SUBMERGENCE), 'depth'];
                    save_file = [location, save_prefix,'.png'];
%                     saveas(gcf, save_file);
                catch
                    continue
                end
            end 
        end
    end
end