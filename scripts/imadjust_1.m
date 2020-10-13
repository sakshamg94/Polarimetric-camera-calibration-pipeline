srcNumIm = 28; % 18 for analyzer
im_ext = '.jpg';
for cam = 1:3
    srcImFolder = ['C:\Users\tracy\Downloads\saksham_polarimetric_cam\',...
        '\cam_',num2str(cam)];
    for x = 1:srcNumIm  
        raw_img = imread([srcImFolder, '\Cam_',num2str(cam),...
            '_Image',num2str(x),im_ext]);
        %         raw_img = double(raw_img);
        correct_img = imadjust(raw_img);
        imwrite(correct_img, [srcImFolder,'_adjusted',...
            '\Cam_',num2str(cam),'_Image',num2str(x),im_ext]);
    end

end

