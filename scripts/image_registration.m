%%
clear
close all
clc
%% Register Images with Projection Distortion Using Control Points
% This example shows how to register two images by selecting control points 
% common to both images and inferring a geometric transformation that aligns the 
% control points.
%% Read Images
% Read the left camera image into the workspace. This image was 
% taken from an airplane and is distorted relative to the orthophoto. Because 
% the unregistered image was taken from a distance and the topography is relatively 
% flat, it is likely that most of the distortion is projective.
% read the right camera image
load('cam_1/cameraParamsCam1.mat')
unregisteredLeft = imread('cam_1/Cam_1_Image10.jpg');
unregisteredLeft = undistortImage(unregisteredLeft, cameraParamsCam1);
subplot(1,3,1);
imshow(unregisteredLeft);
hold on;
title('Left outer Camera')
%%
%Read the reference camera image into the workspace. This image 
% is an orthophoto that has already been registered to the ground.
% this is the reference image
load('cam_3/cameraParamsCam3.mat')
ortho = imread('cam_3/Cam_3_Image10.jpg');
ortho = undistortImage(ortho, cameraParamsCam3);
subplot(1, 3, 2);
imshow(ortho)
hold on;
title('reference camera (middle)')
%% 
% read the right camera image
load('cam_2/cameraParamsCam2.mat')
unregisteredRight = imread('cam_2/Cam_2_Image10.jpg');
unregisteredRight = undistortImage(unregisteredRight, cameraParamsCam2);
subplot(1,3,3);
imshow(unregisteredRight);
hold on;
title('Right outer camera')

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

%% Display the overalapping regions shifted and ready for px to px mapping
figure;
subplot(1,3,1);
imshow(registeredLeft)
title('registered Left outer cam image')
subplot(1,3,2);
imshow(ortho)
title('Center cam image')
subplot(1,3,3);
imshow(registeredRight)
title('registered Right outer cam image')
