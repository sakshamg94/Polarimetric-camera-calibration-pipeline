%% cam = 1;
load('stereoParamaters.mat', 'stereoParams12')
cameraParams_Cam1 = stereoParams12.CameraParameters2;

% Load image at new location.
image_num = 6;
path = 'C:\Users\tracy\Downloads\saksham_polarimetric_cam\';
camPath = ['cam_',num2str(1),'_adjusted\Cam_', num2str(1),'_Image'];
imOrig = imread([path,camPath, num2str(image_num),'.jpg']);
figure 
imshow(imOrig);
title('Input Image');

% Undistort image.
[im,newOrigin] = undistortImage(imOrig,cameraParams_Cam1,'OutputView','full');
figure 
hold on
imshow(im)

% Find reference object in new image.
[imagePoints_Cam1,boardSize] = detectCheckerboardPoints(im);
for i = 1:size(imagePoints_Cam1,1)
    plot(imagePoints_Cam1(i,1), imagePoints_Cam1(i,2),'ro'); hold on
    text(imagePoints_Cam1(i,1), imagePoints_Cam1(i,2),num2str(i), ...
        'Color','Green', 'Fontsize',8, 'Fontweight','bold')
end

% Compensate for image coordinate system shift.
imagePoints_Cam1 = [imagePoints_Cam1(:,1) + newOrigin(1), ...
             imagePoints_Cam1(:,2) + newOrigin(2)];
         
% Compute new extrinsics.
[rotationMatrix_Cam1, translationVector_Cam1] = extrinsics(...
imagePoints_Cam1,cameraParams_Cam1.WorldPoints,cameraParams_Cam1);

%% cam = 2;
load('stereoParamaters.mat', 'stereoParams12')
cameraParams_Cam2 = stereoParams12.CameraParameters1;
% Load image at new location.
image_num = 6;
path = 'C:\Users\tracy\Downloads\saksham_polarimetric_cam\';
camPath = ['cam_',num2str(2),'_adjusted\Cam_', num2str(2),'_Image'];
imOrig = imread([path,camPath, num2str(image_num),'.jpg']);
figure 
imshow(imOrig);
title('Input Image');

% Undistort image.
[im,newOrigin] = undistortImage(imOrig,cameraParams_Cam2,'OutputView','full');
figure 
hold on
imshow(im)

% Find reference object in new image.
[imagePoints_Cam2,boardSize] = detectCheckerboardPoints(im);
for i = 1:size(imagePoints_Cam2,1)
    plot(imagePoints_Cam2(i,1), imagePoints_Cam2(i,2),'ro'); hold on
    text(imagePoints_Cam2(i,1), imagePoints_Cam2(i,2),num2str(i), ...
        'Color','Green', 'Fontsize',8, 'Fontweight','bold')
end

% Compensate for image coordinate system shift.
imagePoints_Cam2 = [imagePoints_Cam2(:,1) + newOrigin(1), ...
             imagePoints_Cam2(:,2) + newOrigin(2)];
         
% Compute new extrinsics.
[rotationMatrix_Cam2, translationVector_Cam2] = extrinsics(...
imagePoints_Cam2,cameraParams_Cam2.WorldPoints,cameraParams_Cam2);

%% cam = 3;
load('stereoParamaters.mat', 'stereoParams23')
cameraParams_Cam3 = stereoParams23.CameraParameters2;
% Load image at new location.
image_num = 6;
path = 'C:\Users\tracy\Downloads\saksham_polarimetric_cam\';
camPath = ['cam_',num2str(3),'_adjusted\Cam_', num2str(3),'_Image'];
imOrig = imread([path,camPath, num2str(image_num),'.jpg']);
figure 
imshow(imOrig);
title('Input Image');

% Undistort image.
[im,newOrigin] = undistortImage(imOrig,cameraParams_Cam3,'OutputView','full');
figure 
hold on
imshow(im)

% Find reference object in new image.
[imagePoints_Cam3,boardSize] = detectCheckerboardPoints(im);
for i = 1:size(imagePoints_Cam3,1)
    plot(imagePoints_Cam3(i,1), imagePoints_Cam3(i,2),'ro'); hold on
    text(imagePoints_Cam3(i,1), imagePoints_Cam3(i,2),num2str(i), ...
        'Color','Green', 'Fontsize',8, 'Fontweight','bold')
end

% Compensate for image coordinate system shift.
imagePoints_Cam3 = [imagePoints_Cam3(:,1) + newOrigin(1), ...
             imagePoints_Cam3(:,2) + newOrigin(2)];
         
% Compute new extrinsics.
[rotationMatrix_Cam3, translationVector_Cam3] = extrinsics(...
imagePoints_Cam3,cameraParams_Cam3.WorldPoints,cameraParams_Cam3);

%% Compute camera pose and plot it in Flume Coordinate system
[orientation_Cam1, location_Cam1] = extrinsicsToCameraPose(rotationMatrix_Cam1, ...
  translationVector_Cam1);
[orientation_Cam2, location_Cam2] = extrinsicsToCameraPose(rotationMatrix_Cam2, ...
  translationVector_Cam2);
[orientation_Cam3, location_Cam3] = extrinsicsToCameraPose(rotationMatrix_Cam3, ...
  translationVector_Cam3);

%plot
figure(45)
plotCamera('Location',location_Cam1,'Orientation',orientation_Cam1,'Size',20);
hold on
plotCamera('Location',location_Cam2,'Orientation',orientation_Cam2,'Size',20);
plotCamera('Location',location_Cam3,'Orientation',orientation_Cam3,'Size',20);

s1 = ['C',num2str(1)];
text(location_Cam1(1), location_Cam1(2), location_Cam1(3)-100, s1, ...
        'Color','Green', 'Fontsize',8, 'Fontweight','bold')
s2 = ['C',num2str(2)];
text(location_Cam2(1), location_Cam2(2), location_Cam2(3)-100, s2, ...
        'Color','Green', 'Fontsize',8, 'Fontweight','bold')
s3 = ['C',num2str(3)];
text(location_Cam3(1), location_Cam3(2), location_Cam3(3)-100, s3, ...
        'Color','Green', 'Fontsize',8, 'Fontweight','bold')
    
pcshow([cameraParams_Cam1.WorldPoints,zeros(size(cameraParams_Cam1.WorldPoints,1),1)], ...
  'VerticalAxisDir','down','MarkerSize',40);
pcshow([cameraParams_Cam2.WorldPoints,zeros(size(cameraParams_Cam2.WorldPoints,1),1)], ...
  'VerticalAxisDir','down','MarkerSize',40);
pcshow([cameraParams_Cam3.WorldPoints,zeros(size(cameraParams_Cam3.WorldPoints,1),1)], ...
  'VerticalAxisDir','down','MarkerSize',40);
% ylim([0 500])
xlabel('X (mm)')
ylabel('Y (mm)')
zlabel('Z (mm)')
% pcshow([imagePoints,zeros(size(imagePoints,1),1)], ...
%   'VerticalAxisDir','down','MarkerSize',40);
% for i = 1:size(imagePoints,1)
%     plot(imagePoints(i,1), imagePoints(i,2),'ro');
%     text(imagePoints(i,1), imagePoints(i,2),num2str(i), ...
%         'Color','Green', 'Fontsize',8, 'Fontweight','bold')
% end