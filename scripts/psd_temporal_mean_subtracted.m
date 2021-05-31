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
                        %                         rng(41);
                        [rows, cols, times] = size(A);
                        %                         r = 1:round(rows/75):rows;%randperm(rows, 75);
                        %                         c = 1:round(cols/75):cols;%randperm(cols, 75);
                        % for mean of 75*75~ 5600 locations
                        
                        x{i,1} = A;
                        clear A
                        %                         counter= 1;
                        %                         for p =1:1:length(r)
                        %                             for q =1:1:length(c)
                        %                                 x{i,1}(:,counter) = A(p,q,:);
                        %                                 counter = counter+1;
                        %                             end
                        %                         end
                    end
                    %%
                    running_sum = sum(x{1,1},3);
                    nums = size(x{1,1},3);
                    for i =2:1:size(x,1)
                        running_sum = running_sum+sum(x{i,1},3);
                        nums = nums+ size(x{1,1},3);
                    end
                    mean_mat = running_sum/nums;
                    for i= 1:1:size(x,1)
                        x{i,1} = x{i,1} - mean_mat;
                    end
                    
                    %%
                    r = 1:round(rows/75):rows;%randperm(rows, 75);
                    c = 1:round(cols/75):cols;%randperm(cols, 75);
                    
                    data = cat(3,x{1,1}(r,c,:)...
                        ,x{2,1}(r,c,:)...
                        ,x{3,1}(r,c,:)...
                        ,x{4,1}(r,c,:));
                    % Now subtract the temporal mean from each location
                    %%
                    fs = 3;
                    data_reshaped = zeros(size(data,3),...
                        size(data,2)*size(data,1));
                    new_col = 0;
                    for i  = 1:1:size(data,1)
                        for j = 1:1:size(data,2)
                            new_col = new_col+1;
                            data_reshaped(:,new_col) = data(i,j,:);
                        end
                    end
                    %%
                    %                     [pxx, f] = pwelch(data_reshaped, [],[],[], fs);
                    nfft=5000;
                    % nfft: default will be 1024 The default nfft is the greater of 256 or the next power of 2 greater than the length of the segments.
                    % Window -- Hamming by default
                    % nOverlap -- 50% of the signal length
                    [pxx, f] = pwelch(data_reshaped,[],[],[], fs);
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