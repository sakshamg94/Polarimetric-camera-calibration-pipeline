clear
close all; clc;
titleStr1= 'Circular ripples (radialy moving sine wave)';
titleStr2 = 'X-Gradient of circular sine wave';
titleStr3 = 'Y-Gradient of circular sine wave';

L = 0.25;
x = 0:5:1023;
y = 0:5:1023;
[X,Y] = meshgrid(x,y);
[nRows, nCols] = size(X);
xmid = x(round(nCols/2));
ymid = y(round(nRows/2));
R = ((X - xmid).^2  + (Y - ymid).^2).^0.5;
kr = 1/30;
A = 0.01;
b = 0;%1/20;
omega = 5;
times = 0:1:60;
%% 
%Now puts this solution inside a 3D matrix 
Vfield_Snapshots = zeros(length(times),size(X,1),size(X,2));
Vxgradfield_Snapshots = zeros(length(times),size(X,1),size(X,2));
Vygradfield_Snapshots = zeros(length(times),size(X,1),size(X,2));

for i =1:length(times)
    t = times(i);
    F  = A * sin(kr * R + omega * t) * exp(-b*t) ;
    dFx = A *kr* exp(-b*t) * cos(kr * R + omega * t) ./ R .*(X - xmid);
    dFy = A *kr* exp(-b*t) * cos(kr * R + omega * t) ./ R .*(Y - ymid);
    Vfield_Snapshots(i,:,:) = F;
    Vxgradfield_Snapshots(i,:,:) = dFx;
    Vygradfield_Snapshots(i,:,:) = dFy;
end

%% 
%Plots the complete solution animation for visualization purposes
MAXVAL = max(abs(Vfield_Snapshots), [], 'all');
MAXxGRADVAL = max(abs(Vxgradfield_Snapshots), [], 'all');
MAXyGRADVAL = max(abs(Vygradfield_Snapshots), [], 'all');

% Initialize video
close all
clc
myVideo = VideoWriter('simulation_radiallyMoving_sine_wave.avi'); %open video file
myVideo.FrameRate = 8;  %can adjust this, 5 - 10 works well for me
open(myVideo)

fi=figure('Color','w');
for i=1:length(times)  
    h(1) = subplot(2,2,1);
    surf(Y*L/y(end),X*L/x(end),...
        squeeze(Vfield_Snapshots(i,:,:)));
    caxis([-MAXVAL MAXVAL])
    colormap redblue
    xlabel('y');
    ylabel('x');
    zlabel('height [m]')
    title(titleStr1);
    colorbar;
    xlim([0 L])
    zlim([-5*MAXVAL 5*MAXVAL])
    ylim([0 L])
    set(gca,'ydir','reverse')
%     axis square

    h(2) = subplot(2,2,2);
    imagesc(y*L/y(end),x*L/x(end),...
        squeeze(Vfield_Snapshots(i,:,:))');
    caxis([-MAXVAL MAXVAL])
    colormap redblue
    xlabel('y');
    ylabel('x');
    title('Top view');
    colorbar;
    xlim([0 L])
    ylim([0 L])
    set(gca,'ydir','reverse')
    axis square

    h(3) = subplot(2,2,3);
    imagesc(y*L/y(end),x*L/x(end),...
        squeeze(Vxgradfield_Snapshots(i,:,:))');
    caxis([-MAXxGRADVAL MAXxGRADVAL])
    colormap redblue
    xlabel('y');
    ylabel('x');
    title(titleStr2);
    colorbar;
    xlim([0 L])
    ylim([0 L])
    set(gca,'ydir','reverse')
    axis square

    h(4) = subplot(2,2,4);
    imagesc(y*L/y(end),x*L/x(end),...
        squeeze(Vygradfield_Snapshots(i,:,:))');
    caxis([-MAXyGRADVAL MAXyGRADVAL])
    colormap redblue
    xlabel('y');
    ylabel('x');
    title(titleStr3);
    colorbar;
    xlim([0 L])
    ylim([0 L])
    set(gca,'ydir','reverse')
    axis square
   
    ax = gcf;
    ax.Position = [49.5000 134.5000 1.2755e+03 675.5000];

    drawnow;
    pause(0.01)    %Pause and grab frame

    frame = getframe(gcf); %get frame
    writeVideo(myVideo, frame);
end
close(myVideo)