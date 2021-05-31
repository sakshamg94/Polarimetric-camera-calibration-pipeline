dirPath = '../TOSHIBA_Drive/saksham_polar_cam_FLIR/';
folder = 'boils_3fps_25Pump_25cmH_industrialHose';
video = VideoWriter([dirPath, '/', folder,'/','vid.avi']); %create the video object
video.FrameRate = 4;
open(video); %open the file for writing
files=dir([dirPath, '/', folder]);
for ii=350:600 %where N is the number of images
  I = imread([dirPath, '/', folder,'/',files(ii).name]); %read the next image
  img = I(2:2:end,1:2:end,1)+ 20;
  writeVideo(video,img); %write the image to file
end
close(video); %close the file