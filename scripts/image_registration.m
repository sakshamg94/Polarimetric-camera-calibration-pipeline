%%
clear
close all
clc
%% Register Images with Projection Distortion Using Control Points
% This example shows how to register two images by selecting control points 
% common to both images and inferring a geometric transformation that aligns the 
% control points.
image_num = 1;
%% Read Images
% Read the left camera image into the workspace. This image was 
% taken from an airplane and is distorted relative to the orthophoto. Because 
% the unregistered image was taken from a distance and the topography is relatively 
% flat, it is likely that most of the distortion is projective.
% read the right camera image
load('C:\Users\tracy\Downloads\saksham_polarimetric_cam\cam1_params.mat')
cameraParamsCam1 = cameraParams;
D1 = D;
F1 = F;
m1 = m;
unregisteredLeft = imread(['C:\Users\tracy\Downloads\saksham_polarimetric_cam\cam_1\Cam_1_Image',num2str(image_num),'.jpg']);
% unregisteredLeft = (unregisteredLeft - D1)./(F1-D1) .* m1;
% figure(23); imshow(unregisteredLeft)
% unregisteredLeft = undistortImage(unregisteredLeft, cameraParamsCam1);
subplot(1,3,1);
imshow(unregisteredLeft);
hold on;
title('Left outer Camera (1:C6)')
%%
%Read the reference camera image into the workspace. This image 
% is an orthophoto that has already been registered to the ground.
% this is the reference image
load('C:\Users\tracy\Downloads\saksham_polarimetric_cam\cam2_params.mat')
cameraParamsCam2 = cameraParams;
D2 = D;
F2 = F;
m2 = m;
ortho = imread(['C:\Users\tracy\Downloads\saksham_polarimetric_cam\cam_2\Cam_2_Image',num2str(image_num),'.jpg']);
% figure(24); imshow(ortho)
% ortho = (ortho - D2)./(F2-D2) .* m2;
% ortho = undistortImage(ortho, cameraParamsCam2);
subplot(1, 3, 2);
imshow(ortho)
hold on;
title('reference camera (middle; 2:C7)')
%% 
% read the right camera image
load('C:\Users\tracy\Downloads\saksham_polarimetric_cam\cam3_params.mat')
cameraParamsCam3 = cameraParams;
D3 = D;
F3 = F;
m3 = m;
unregisteredRight = imread(['C:\Users\tracy\Downloads\saksham_polarimetric_cam\cam_3\Cam_3_Image',num2str(image_num),'.jpg']);
% unregisteredRight = (unregisteredRight - D3)./(F3-D3) .* m3;
% unregisteredRight = undistortImage(unregisteredRight, cameraParamsCam3);
subplot(1,3,3);
imshow(unregisteredRight);
hold on;
title('Right outer camera (3:C2)')

%% Select Control Point Pairs
% To select control points interactively, open the Control Point Selection tool 
% by using the <docid:images_ref#bvh0ia0-1 |cpselect|> function. Control points 
% are landmarks that you can find in both images, such as a road intersection 
% or a natural feature. Select at least four pairs of control points so that |cpselect| 
% can fit a projective transformation to the control points. After you have selected 
% corresponding moving and fixed points, close the tool to return to the workspace.

% --- manual selection of key/control points -- %
% [movingPoints,fixedPoints] = cpselect(unregistered,ortho,'Wait',true);


% -- automatic selection of key/control points --%
%1. find the checkerboard points for Left outercam image
subplot(1,3,1);
[movingPointsLeft,b1] = detectCheckerboardPoints(unregisteredLeft);
% plot the fixed points
for i = 1:size(movingPointsLeft,1)
    plot(movingPointsLeft(i,1), movingPointsLeft(i,2),'ro');
    text(movingPointsLeft(i,1), movingPointsLeft(i,2),num2str(i), 'Color','Green', 'Fontsize',8, 'Fontweight','bold')
end

%2.  find the checkerboard points for reference image
subplot(1,3,2);
[fixedPoints,b] = detectCheckerboardPoints(ortho);
% plot the fixed points
for i = 1:size(fixedPoints,1)
    plot(fixedPoints(i,1), fixedPoints(i,2),'ro');
    text(fixedPoints(i,1), fixedPoints(i,2),num2str(i), 'Color','Green', 'Fontsize',8, 'Fontweight','bold')
end

%3. find the checkerboard points for Left outercam image
subplot(1,3,3);
[movingPointsRight,b2] = detectCheckerboardPoints(unregisteredRight);
% plot the fixed points
for i = 1:size(movingPointsRight,1)
    plot(movingPointsRight(i,1), movingPointsRight(i,2),'ro');
    text(movingPointsRight(i,1), movingPointsRight(i,2),num2str(i), 'Color','Green', 'Fontsize',8, 'Fontweight','bold')
end
%% Infer Geometric Transformation
% Find the parameters of the projective transformation that best aligns the 
% moving and fixed points by using the <docid:images_ref#btxcscn-1 |fitgeotrans|> 
% function.

% projective and non-reflective similarity transforms give simialar results
% -- visually at least

% tLC = fitgeotrans(movingPointsLeft,fixedPoints,'nonreflectivesimilarity');% non reflective similarity
% tRC = fitgeotrans(movingPointsRight,fixedPoints,'nonreflectivesimilarity');% non reflective similarity
tLC = fitgeotrans(movingPointsLeft,fixedPoints,'projective');% non reflective similarity
tRC = fitgeotrans(movingPointsRight,fixedPoints,'projective');% non reflective similarity

% See Transformation types here: https://www.mathworks.com/help/images/ref/fitgeotrans.html#bvonaug

%% Transform Unregistered Image
% To apply the transformation to the unregistered aerial image, use the <docid:images_ref#btqog63-1 |imwarp|> function. Specify that the size 
% and position of the transformed image match the size and position of the ortho 
% image by using the OutputView name-value pair argument.

Rfixed = imref2d(size(ortho));
registeredLeft = imwarp(unregisteredLeft,tLC,'OutputView',Rfixed);
registeredRight = imwarp(unregisteredRight,tRC,'OutputView',Rfixed);
%% 
% See the result of the registration by overlaying the transformed image over 
% the original orthophoto.
figure;
subplot(1,2,1);
imshowpair(ortho,registeredLeft,'blend')
title('Left registered image -- blended with center')
subplot(1,2,2);
imshowpair(ortho,registeredRight,'blend')
title('Right registered image -- blended with center')

close; figure(8);
imshow((imread('C:\Users\tracy\Downloads\saksham_polarimetric_cam\cam_2_expt\Cam_2_Image1.png')))
roi = drawrectangle;
roi.Position
%% Display the overalapping regions shifted and ready for px to px mapping
figure;
subplot(1,3,1);
imshow(registeredLeft)
title('registered Left outer cam image')
subplot(1,3,2);
imshow(imadjust(ortho))
title('Center cam image')
subplot(1,3,3);
imshow(registeredRight)
title('registered Right outer cam image')

%% Save registration and Cropping params
% for cropping params -- open themiddle camera image (Cam_2) and figur
% manually using a rectangle
disp('Manual: cut 250 px on each left and right side and 35 pixels top, 10 bottom')
% top = 50;
% bot = 50;
% left = 200;
% right = 200;
imshow(Cam_2_Image1);
roi = drawrectangle;
top = floor(roi.Position(2));
bot = floor(1026 - roi.Position(2) - roi.Position(4));
left = floor(roi.Position(1));
right = floor(1282 - roi.Position(1) - roi.Position(3));
% save('C:\Users\tracy\Downloads\saksham_polarimetric_cam\im_registration_params.mat','tLC','tRC','Rfixed',...
%     'top', 'bot', 'left', 'right')
save('C:\Users\tracy\Downloads\saksham_polarimetric_cam\im_registration_params.mat',...
    'top', 'bot', 'left', 'right', '-append')
