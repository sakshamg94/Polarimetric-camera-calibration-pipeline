clear
clc
close all
% gigecamlist % to list the cameras attached to the pC
%imaqtool
%imaqreset
%% basic acquisition settings
% num Frames from how many you need
% # Last image for camera geometric calibration has to be stable and 
% # static held pattern for all the 3 cameras
numFrames = 32; %more than 1k does not work with the exposure, has be >=2
exposure = 6000;
acquiring = 1;
%% Create a videoinput with the desired video format and get access to the
%camera device specific properties.
% When using the videoinput gige adaptor, the camera GenICam features
%and parameter values are represented as videoinput source properties.
%L--C--R::
%2:1:3:: % from gigecamlist
%C6:C7:C2(absolute lab & code frame)
% (left)v1:v2(mid):v3(right) (absolute lab & code frame)
gigecamlist
% check the numbering each time please. It keeps changing!!

v1 = videoinput('gige',2, 'Mono8'); % C6    
s1 = v1.Source; % open and check s1 is C6
assert(s1.DeviceUserID(2) == '6', 'check_cam_numbering')

v2 = videoinput('gige',3, 'Mono8'); % C7
s2 = v2.Source; % open and check s1 is C7
assert(s2.DeviceUserID(2) == '7', 'check_cam_numbering')

v3 = videoinput('gige',1, 'Mono8'); % C2
s3 = v3.Source; % open and check s1 is C2
assert(s3.DeviceUserID(2) == '2', 'check_cam_numbering')
%% Specify 'hardware' videoinput trigger type for func generator triggering
triggerconfig(v1, 'hardware', 'DeviceSpecific', 'DeviceSpecific');
triggerconfig(v2, 'hardware', 'DeviceSpecific', 'DeviceSpecific');
triggerconfig(v3, 'hardware', 'DeviceSpecific', 'DeviceSpecific');

%% configure the camera for the frame starter mode
% and specify external triggering signal input line& desired trigger condition.
% This requires setting the TriggerSelector first; once a TriggerSelector
% value is selected, setting a trigger property (for example,
% TriggerMode to 'on') applies only to the specified trigger mode (FrameStart).
% get(getselectedsource(v))
s1.TriggerSelector = 'FrameStart';
s1.TriggerSource = 'Line1';
s1.TriggerActivation = 'RisingEdge';
s1.TriggerMode = 'On';
% Specify a constant exposure time for each frame
s1.ExposureMode = 'Timed';
s1.ExposureTimeAbs = exposure; %default is 5000 microseconds
%
s2.TriggerSelector = 'FrameStart';
s2.TriggerSource = 'Line1';
s2.TriggerActivation = 'RisingEdge';
s2.TriggerMode = 'On';
% Specify a constant exposure time for each frame
s2.ExposureMode = 'Timed';
s2.ExposureTimeAbs = exposure;
%
s3.TriggerSelector = 'FrameStart';
s3.TriggerSource = 'Line1';
s3.TriggerActivation = 'RisingEdge';
s3.TriggerMode = 'On';
% Specify a constant exposure time for each frame
s3.ExposureMode = 'Timed';
s3.ExposureTimeAbs = exposure;

%% Frame Trigger starter
% Specify total number of frames to be acquired
% One frame is acquired for each external signal pulse.

% You have to put the TPeriod to be the 1/fps you want on the func generatr
% Use Pulse delay to be 10ms
% Use Pulse Width to be say 20ms -- somehow related to exposure.. but you
% set it separately too?
% packet size and packet delay configs
v1.FramesPerTrigger = 1;
v2.FramesPerTrigger = 1;
v3.FramesPerTrigger = 1;
v1.TriggerRepeat = numFrames - 1;
v2.TriggerRepeat = numFrames - 1;
v3.TriggerRepeat = numFrames - 1;

%% Determine optimum streaming parameters as described in the
% "GigE Vision Quick Start Configuration Guide"
framesPerSecond = CalculateFrameRate(v3, numFrames);
delay3 = CalculatePacketDelay(v3, framesPerSecond);
framesPerSecond = CalculateFrameRate(v1, numFrames);
delay1 = CalculatePacketDelay(v1, framesPerSecond);
framesPerSecond = CalculateFrameRate(v2, numFrames);
delay = CalculatePacketDelay(v2, framesPerSecond);
% Determine optimum streaming parameters as described in the
% "GigE Vision Quick Start Configuration Guide"

%% Start hardware-triggered buffered continuous acquisition, and wait for
% acquisition to complete
pktSize = 4000;
% dont forget to make receive descripters = max value in driver (4096)
% also jumbo frame rate = all applications in driver
% aslo packetsize is slightly smaller than the receive descripter value
s1.PacketSize = pktSize;
s2.PacketSize = pktSize;
s3.PacketSize = pktSize; 
s1.PacketDelay = delay;
s2.PacketDelay = delay;
s3.PacketDelay = delay;

% these are necessary bec packet delay function causes trigger to go off
s1.TriggerMode = 'On'; 
s2.TriggerMode = 'On';
s3.TriggerMode = 'On';
start([v1, v2 ,v3])
recordTime = max(10,round(1.5/framesPerSecond*numFrames));
wait([v1, v2 ,v3], 60*recordTime)

% Transfer acquired frames and timestamps from acquisition input buffer
% into workspace
disp('Acquiring data...')
[data1, ts1] = getdata(v1, v1.FramesAvailable);
[data2, ts2] = getdata(v2, v2.FramesAvailable);
[data3, ts3] = getdata(v3, v3.FramesAvailable);
% size(data1)
% H(1026) Image height, as specified in the object's ROIPosition property
% W(1282) Image width, as specified in the object's ROIPosition property
% B(1) Number of color bands, as specified in the NumberOfBands property
% F(numFrames) The number of frames returned

%%% Display acquired frames and plot timestamp differences, 
%which correspond to the 25 Hz frequency of the external triggering signal.
close all
figure(51);
imaqmontage(data1)
figure(52);
imaqmontage(data2)
figure(53);
imaqmontage(data3)


% for i = 1:10
%     figure(70+i)
%     subplot(3,1,1); imshow(data1(:,:,1,i)); 
%     subplot(3,1,2); imshow(data2(:,:,1,i)); 
%     subplot(3,1,3); imshow(data3(:,:,1,i));
% end

% figure; hold on;
% plot(diff(ts1), 'k*-')
% plot(diff(ts2), 'r*-')
% plot(diff(ts3), 'b*-')
% legend('ch1', 'ch2', 'ch3')
% xlabel('Frame index');
% ylabel('diff(Timestamp) (s)');
% 
% figure; hold on;
% plot(ts1, 'k*-')
% plot(ts2, 'r*-')
% plot(ts3, 'b*-')
% legend('ch1', 'ch2', 'ch3')
% xlabel('Frame index');
% ylabel('Timestamp (s)');
% 


%% save the frames for Geometric calibration (checkerboard)
% disp('Acq done, saving frames...')
for x = numFrames
    filename=strcat('Cam_1_Image',int2str(x-1),'.jpg'); %  OR JPEG AS  YOU LIKE
    delete(filename);
    imwrite(data1(:,:,:,x),strcat('cam_1/',filename));
end
for x =numFrames
    filename=strcat('Cam_2_Image',int2str(x-1),'.jpg'); %  OR JPEG AS  YOU LIKE
    delete(filename);
    imwrite(data2(:,:,:,x),strcat('cam_2/',filename));
end
for x =numFrames %bh5 m
    filename=strcat('Cam_3_Image',int2str(x-1),'.jpg'); %  OR JPEG AS  YOU LIKE
    delete(filename);
    imwrite(data3(:,:,:,x),strcat('cam_3/',filename));
end

%% save the frames for flat and dark field calibration 
% flat, dark, expt ones
% for x = 1:numFrames
%     filename=strcat('Cam_1_Image',int2str(x),'.png'); %  OR JPEG AS  YOU LIKE
%     delete(filename);
%     imwrite(data1(:,:,1,x),strcat('cam_1_expt/',filename));
% end
% for x = 1:numFrames
%     filename=strcat('Cam_2_Image',int2str(x),'.png'); %  OR JPEG AS  YOU LIKE
%     delete(filename);
%     imwrite(data2(:,:,1,x),strcat('cam_2_expt/',filename));
% end
% for x = 1:numFrames %bh5 m
%     filename=strcat('Cam_3_Image',int2str(x),'.png'); %  OR JPEG AS  YOU LIKE
%     delete(filename);
%     imwrite(data3(:,:,1,x),strcat('cam_3_expt/',filename));
% end

%% save the frames for Analyzer Matrix calibration
% disp('Acq done, saving frames...')
% for x = numFrames
%     filename=strcat('Cam_1_Image',int2str(x-1),'.jpg'); %  OR JPEG AS  YOU LIKE
%     delete(filename);
%     imwrite(data1(:,:,:,x),strcat('cam_1_Analyzer_Matrix/',filename));
% end
% for x = numFrames
%     filename=strcat('Cam_2_Image',int2str(x-1),'.jpg'); %  OR JPEG AS  YOU LIKE
%     delete(filename);
%     imwrite(data2(:,:,:,x),strcat('cam_2_Analyzer_Matrix/',filename));
% end
% for x = numFrames %bh5 m
%     filename=strcat('Cam_3_Image',int2str(x-1),'.jpg'); %  OR JPEG AS  YOU LIKE
%     delete(filename);
%     imwrite(data3(:,:,:,x),strcat('cam_3_Analyzer_Matrix/',filename));
% end
%% flat, dark
% %flat, dark, %expt ones
% for x = 1:numFrames
%     filename=strcat('Cam_1_Image',int2str(x),'.png'); %  OR JPEG AS  YOU LIKE
%     delete(filename);
%     imwrite(data1(:,:,1,x),strcat('cam_1_dark/',filename));
% end
% for x = 1:numFrames
%     filename=strcat('Cam_2_Image',int2str(x),'.png'); %  OR JPEG AS  YOU LIKE
%     delete(filename);
%     imwrite(data2(:,:,1,x),strcat('cam_2_dark/',filename));
% end
% for x = 1:numFrames %bh5 m
%     filename=strcat('Cam_3_Image',int2str(x),'.png'); %  OR JPEG AS  YOU LIKE
%     delete(filename);
%     imwrite(data3(:,:,1,x),strcat('cam_3_dark/',filename));
% end

%% expt
% for x = 1:numFrames
%     filename=strcat('Cam_1_Image',int2str(x),'.png'); %  OR JPEG AS  YOU LIKE
%     delete(filename);
%     imwrite(data1(:,:,1,x),strcat('cam_1_expt/',filename));
% end
% for x = 1:numFrames
%     filename=strcat('Cam_2_Image',int2str(x),'.png'); %  OR JPEG AS  YOU LIKE
%     delete(filename);
%     imwrite(data2(:,:,1,x),strcat('cam_2_expt/',filename));
% end
% for x = 1:numFrames %bh5 m
%     filename=strcat('Cam_3_Image',int2str(x),'.png'); %  OR JPEG AS  YOU LIKE
%     delete(filename);
%     imwrite(data3(:,:,1,x),strcat('cam_3_expt/',filename));
% end

%%
% if acquiring~=1
%     delete(v1)
%     delete(v2)
%     delete(v3)
% end
%% rectification of images using stereoparametrs
% load('stereoParams23.mat')
% %[J1,J2] = rectifyStereoImages(data2(:,:,1,1),data3(:,:,1,1),stereoParams23)
% [J1,J2] = rectifyStereoImages(data2(:,:,1,1),data3(:,:,1,1),stereoParams23, 'OutputView', 'Full')