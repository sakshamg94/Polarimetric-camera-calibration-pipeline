% the flat image
image_num = 28;
%%
for cam =1:1:3
% clearvars -except cam
% Load image at new location.

path = 'C:\Users\tracy\Downloads\saksham_polarimetric_cam\';
camPath = ['cam_',num2str(cam),'_adjusted\Cam_', num2str(cam),'_Image'];
imOrig = imread([path,camPath, num2str(image_num),'.jpg']);
figure 
imshow(imOrig);
title('Input Image');

%load
load(['cam',num2str(cam),'_params.mat'])

% Undistort image.
[im,newOrigin] = undistortImage(imOrig,cameraParams,'OutputView','full');
figure 
imshow(im)
hold on
% Find reference object in new image.
[imagePoints,boardSize] = detectCheckerboardPoints(im);
for i = 1:size(imagePoints,1)
    plot(imagePoints(i,1), imagePoints(i,2),'ro'); hold on
    text(imagePoints(i,1), imagePoints(i,2),num2str(i), ...
        'Color','Green', 'Fontsize',8, 'Fontweight','bold')
end

% Compensate for image coordinate system shift.
imagePoints = [imagePoints(:,1) + newOrigin(1), ...
             imagePoints(:,2) + newOrigin(2)];
         
% Compute new extrinsics.
[rotationMatrix, translationVector] = extrinsics(...
imagePoints,cameraParams.WorldPoints,cameraParams);

%% Compute camera pose.
[orientation, location] = extrinsicsToCameraPose(rotationMatrix, ...
  translationVector);
figure(45)
plotCamera('Location',location,'Orientation',orientation,'Size',20);
hold on
s = ['C',num2str(cam)];
text(location(1), location(2), location(3)-100, s, ...
        'Color','Green', 'Fontsize',8, 'Fontweight','bold')
pcshow([cameraParams.WorldPoints,zeros(size(cameraParams.WorldPoints,1),1)], ...
  'VerticalAxisDir','down','MarkerSize',40);
% ylim([0 500])
xlabel('X (mm)')
ylabel('Y (mm)')
zlabel('Z (mm)')
end