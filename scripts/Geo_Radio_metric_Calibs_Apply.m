squareSize = 13.5; %mm
for cam = 1:3
    srcImFolder = ['C:\Users\tracy\Downloads\saksham_polarimetric_cam\',...
        '\cam_',num2str(cam),'_Analyzer_Matrix'];
    
    % number of images to correct
    srcNumIm = 18;
    
    % number of flat field images
    numIm = 20; 
    
    %Radiometric calib params
    [F, D, m] = flat_field_correction(cam, numIm, 1026, 1282);
    
    %Geometric calib params
    cameraParams = geometricCalibration(cam , squareSize);
    
    % correct all src images
    for x = 1:srcNumIm
        
        raw_img = imread([srcImFolder, '\Cam_',num2str(cam),...
            '_Image',num2str(x),'.jpg']);
        raw_img = double(raw_img);
        
        % Apply Radiometric (flat field) correction
%         F = 255*ones(1026, 1282);
%         correct_img = (raw_img - D)./(F-D) .* m;
        correct_img = raw_img;
        % Apply Geometric correction 
        correct_img = undistortImage(correct_img, cameraParams);
        
        %
%         correct_img = im2uint8(correct_img, 'indexed'); 
        
        % write the corrected (calibrated) image
        save([srcImFolder, '\Cam_',num2str(cam),...
            '_Image',num2str(x),'RadioGeoCorrect.mat'], 'correct_img')
    
    end
    
    % write camera sensitive params
    save(['cam',num2str(cam),'_params.mat'], 'cameraParams', 'F', 'D', 'm');
end