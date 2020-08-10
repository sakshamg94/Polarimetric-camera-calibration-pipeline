function [F, D, m] = flat_field_correction(cam,numIm,imHeight,imWidth)

flat_images = zeros(imHeight, imWidth, numIm);
dark_images = zeros(imHeight, imWidth, numIm);

for x=1:numIm-1
    flat_images(:,:,x)= ...
        imread(['C:\Users\tracy\Downloads\saksham_polarimetric_cam\',...
        'cam_',num2str(cam),'_flat\Cam_',...
        num2str(cam),'_Image',num2str(x-1),'.jpg']);
    dark_images(:,:,x)= ...
        imread(['C:\Users\tracy\Downloads\saksham_polarimetric_cam\',...
        'cam_',num2str(cam),'_dark\Cam_',...
        num2str(cam),'_Image',num2str(x-1),'.jpg']);
end
F = mean(flat_images,3);
D = mean(dark_images,3);
m = mean(F-D,[1,2]);
end

%% Plotting
% figure;
% subplot(2,2,1);
% hold on;
% imshow(F, [0, 255])
% title('Average flat field image (F)')
% 
% subplot(2,2,2);
% hold on;
% imshow(D, [0, 255])
% title('Average Dark image (D)')
% 
% subplot(2,2,3);
% hold on;
% imshow(raw_img, [0, 255])
% title('Raw image')
% 
% subplot(2,2,4);
% hold on;
% imshow(correct_img, [0, 255])
% title('Corrected image')
% correct_img, F, D, m