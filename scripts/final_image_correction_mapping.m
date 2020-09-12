%% File to process all experimental images using pre-evaluated parameters
% Apply Flat field correction
% Apply Geometric correction
% Apply Image Mapping via Image Registration
% Crop images to contain overlapping region
% Save the resulting mat-files -- keep double format
%%
src = '_Analyzer_Matrix'; %'_Analyzer_Matrix'; % or '_expt' % extension of teh source folder 
srcNumIm = 18; % 18 for analyzer

if strcmp(src,'_Analyzer_Matrix')
    savefname = 'final_map_Analyzer_Images.mat';
    im_ext = '.jpg';
elseif strcmp(src,'_expt')
    savefname = 'final_map.mat';
    im_ext = '.png';
else 
end

%%
% load the image registration map transform and cropping params
load('C:\Users\tracy\Downloads\saksham_polarimetric_cam\im_registration_params.mat')


% map of the overlapped images from the 3 cameras
new_map = zeros(1026-top-bot, 1282-left-right, 3, srcNumIm, 'uint8');

for cam = 1:3
    srcImFolder = ['C:\Users\tracy\Downloads\saksham_polarimetric_cam\',...
        '\cam_',num2str(cam),src];
    
    %Radiometric calib params
    %     load(['../cam', num2str(cam),'_params.mat'])
    
    for x = 1:srcNumIm
        
        raw_img = imread([srcImFolder, '\Cam_',num2str(cam),...
            '_Image',num2str(x),im_ext]);
        %         raw_img = double(raw_img);
        correct_img = raw_img;
        
        % Apply Radiometric (flat field) correction
        %         correct_img = (raw_img - D)./(F-D) .* m;
        
        % Apply Geometric correction
        %         correct_img = undistortImage(correct_img, cameraParams);
        
        % Apply Image Mapping via Image Registration
        if cam==1
            correct_img = imwarp(correct_img,tLC,'OutputView',Rfixed);
        elseif cam==3
            correct_img = imwarp(correct_img,tRC,'OutputView',Rfixed);
        else
        end
        
        % Crop images & save to final map to contain overlapping region
        new_map(:,:,cam,x) = ...
            correct_img(top+1:1026-bot, left+1:1282-right);
    end
    
    % write camera sensitive params
    % For variables larger than 2GB use MAT-file version 7.3 or later.
    file = ['C:\Users\tracy\Downloads\saksham_polarimetric_cam\',savefname];
    save(file , 'new_map', '-v7.3'); % about 3-4 mins
end
