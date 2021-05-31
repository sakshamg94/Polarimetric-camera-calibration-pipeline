%% plot the pdf from the entire time series data
% load
num_pts = 8;
for flow_idx  =1%:3
    for submergence_idx = 3
        for bed_idx = 2
            for quantity_idx = 2
                try
                    x = {};
                    data = [];
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
                        x{i,1} = permute(A(:,1:100:end,:), [3,1,2]);
                        
                    end
                    %%
                    running_sum = sum(x{1,1},1);
                    nums = size(x{1,1},1);
                    for i =2:1:size(x,1)
                        running_sum = running_sum+sum(x{i,1},1);
                        nums = nums+ size(x{1,1},1);
                    end
                    mean_mat = running_sum/nums;
                    for i= 1:1:size(x,1)
                        x{i,1} = x{i,1} - mean_mat;
                    end
                    
                    data = cat(1,x{1,1},x{2,1},x{3,1},x{4,1});
                    %%
                    % have not seen how sensititve this is
                    % to the initial locaiton x
                    xcf = crosscorr(data(:,1,1),data(:,2,1),'NumLags',200);
                    num_lags = size(xcf,1);
                    num_deltaX = size(data,2);
                    num_Ylocs = size(data,3);
                    xcf = zeros(num_lags,num_deltaX, num_Ylocs);
                    tic;
                    for c  = 1:1:num_Ylocs
                        for i = 1:1:num_deltaX
                            [xcf(:,i,c), lag,~] = crosscorr(data(:,1,c),...
                                data(:,i,c),'NumLags',200);
                        end
                    end
                    disp(toc)
                    close all
                    figure(1);
                    hold on
                    
                    xcf_col_mean = mean(xcf,3);
                    delta_x = 1;
                    physical_delta_x=delta_x*0.0115*2;
                    fs = 3;
                    lags = lag/fs;
                    for i  = 2:500:size(xcf,2)
                        txt =  sprintf('\\Delta x = %.1fcm',...
                            (i-1)*physical_delta_x);
                        plot(lags,xcf(:,i),'DisplayName', txt)
                        hold on
                    end
                    grid on
                    legend show
                    xlabel("Time lag(s)")
                    ylabel("X-Corr")
                    
                    title_str = [title_quant{quantity_idx},': ',...
                        upper(BEDFORM),' ',FLOW_SPEED,'-Flow ',SUBMERGENCE,' H'];
                    %                     title(title_str)
                    %
                    %                     location = '../FLIR_Camera/xcorr_functions/';
                    %                     save_prefix = [save_quant{quantity_idx},'_',upper(BEDFORM), '_',...
                    %                         upper(FLOW_SPEED),'flow_', upper(SUBMERGENCE), 'depth'];
                    %                     save_file = [location, save_prefix,'.png'];
                    %                     saveas(gcf, save_file);
                    %%
                    
                    fourierTransform = fft2(xcf_col_mean);
                    timeFreqAxis = [0 size(fourierTransform,1)/fs];
                    
                    spaceX = size(fourierTransform,2);
                    kx = (-spaceX/2+0.5:1:spaceX/2-0.5)*43.4;
                    k_mult = repmat(kx.^4, [size(fourierTransform,1),1]);
                    fft_log_shifted = log(abs(fftshift(fourierTransform,2)));
                    fft_log_shifted(fft_log_shifted > 4) = 0;
                    fft_log_shifted(fft_log_shifted < -2) = 0;
                    spaceFreqAxis = [min(kx) max(kx)];
                    figure(3)
                    imagesc(spaceFreqAxis, timeFreqAxis, fft_log_shifted)
                    hold on;
                    ylabel('\omega (Hz)', 'FontSize',12)
                    xlabel('k_x (cm^{-1})', 'FontSize',12)
                    title('Spectrum of space-time correlation of Sx^\prime')
                    set(gca,'Ydir','reverse')
                    colormap('jet')
                    colorbar()
                catch e
                    %e is an MException struct
                    fprintf(1,'The identifier was:\n%s',e.identifier);
                    fprintf(1,'There was an error! The message was:\n%s',e.message);
                    continue
                end
            end
        end
    end
end