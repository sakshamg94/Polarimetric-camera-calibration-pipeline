%% plot the pdf from the entire time series data
% load
num_pts = 8;
for flow_idx  =1%:3
    for submergence_idx = 3
        for bed_idx = 1
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
                        rng(41);
                        [rows, cols, times] = size(A);
                        r = 1:round(rows/num_pts):rows;%randperm(rows, 75);
                        disp(round(rows/num_pts))
                        c =round(cols/2);%randperm(cols, 75);
                        % for mean of 75*75~ 5600 locations
                        
                        x{i,1} = zeros(times, length(r));
                        counter= 1;
                        for p =1:1:length(r)
                            x{i,1}(:,counter) = A(p,c,:);
                            counter = counter+1;
                        end
                    end
                    %%
                    data = cat(1,x{1,1},x{2,1},x{3,1},x{4,1});
                    %%
                    % have not seen how sensititve this is
                    % to the initial locaiton x
                    xcf = crosscorr(data(:,1),data(:,2),'NumLags',200);
                    xcf = zeros(size(xcf,1),num_pts);
                    for i = 1:1:num_pts
                        [xcf(:,i), lag,~] = crosscorr(data(:,1),...
                            data(:,i),'NumLags',200);
                    end
                    
                    close all
                    figure(1);
                    hold on
                    
                    delta_x = round(rows/num_pts);
                    physical_delta_x=delta_x*0.0115*2;
                    fs = 3;
                    lags = lag/fs;
                    for i  = 2:2:size(xcf,2)
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
                        upper(BEDFORM),' ',FLOW_SPEED,'-Flow ',SUBMERGENCE,' H']
                    title(title_str)
                    
                    location = '../FLIR_Camera/xcorr_functions/';
                    save_prefix = [save_quant{quantity_idx},'_',upper(BEDFORM), '_',...
                        upper(FLOW_SPEED),'flow_', upper(SUBMERGENCE), 'depth'];
                    save_file = [location, save_prefix,'.png'];
%                     saveas(gcf, save_file);
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
%%
close all
figure(3)
for i  = 2:2:size(xcf,2)
    txt =  sprintf('\\Delta x = %.1fcm',...
        (i-1)*physical_delta_x);
    subplot(2,2,i/2);
    plot((1:1:size(data,1))./fs,data(:,i),'DisplayName', txt)
    hold on
    title(txt)
    yline(0);
    grid on
%     legend show
    xlabel("Time (s)")
    ylabel("streamwise slope")
end

%%
% close all
% [pxx,f] = pwelch(data(:,i) - mean(data(:,i)));
% loglog(pxx)