%% File to process all experimental images using pre-evaluated parameters
% Apply Flat field correction
% Apply Geometric correction
% Apply Image Mapping via Image Registration
% Crop images to contain overlapping region
% Save the resulting mat-files -- keep double format
%%
% load the image registration map transform and cropping params
load('C:\Users\tracy\Downloads\saksham_polarimetric_cam\im_registration_params.mat')

% number of images to correct
srcNumIm = 1;

% map of the overlapped images from the 3 cameras
final_map = zeros(1026-top-bot, 1282-left-right, 3, srcNumIm, 'uint8');

for cam = 1:3
    srcImFolder = ['C:\Users\tracy\Downloads\saksham_polarimetric_cam\',...
        '\cam_',num2str(cam),'_expt'];
    
    %Radiometric calib params
    %     load(['../cam', num2str(cam),'_params.mat'])
    
    for x = 1:srcNumIm
        
        raw_img = imread([srcImFolder, '\Cam_',num2str(cam),...
            '_Image',num2str(x),'.png']);
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
        final_map(:,:,cam,x) = ...
            correct_img(top+1:1026-bot, left+1:1282-right);
    end
    
    % write camera sensitive params
    % For variables larger than 2GB use MAT-file version 7.3 or later.
    save('C:\Users\tracy\Downloads\saksham_polarimetric_cam\final_map.mat', 'final_map', '-v7.3'); % about 3-4 mins
end
