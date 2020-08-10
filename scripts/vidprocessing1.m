close all; clc
v = VideoReader('coral1.avi');
num_frames = 800;
init = 2801;
for img = init:1:init+num_frames%v.FrameRate*v.Duration
    video = readFrame(v);
    filename=strcat('coral1/frame',num2str(img),'.png');
    %     figure;clf
    %     imshow(video);
    imwrite(video,filename);
end
%%
for i = 1:num_frames
    im(i).image = rgb2gray(imread(strcat('coral1/frame', num2str(i), '.png')));
    imwrite(im(i).image,strcat('coral1/frame', num2str(i), '.bmp'),'bmp');
end
