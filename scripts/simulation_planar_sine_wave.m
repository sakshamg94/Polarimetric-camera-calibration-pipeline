clear
close all; clc;
titleStr1= 'Monochromatic sine wave';
titleStr2 = 'X-Gradient of sine wave';
L = 0.25;
x = 0:3:1024;
y = 0:3:1024;
[X,Y] = meshgrid(x,y);
kx = 1/8;
A = 0.01;
b = 0;%1/20;
omega = 5;
times = 0:1:60;
%% 
%Now puts this solution inside a 3D matrix 
Vfield_Snapshots = zeros(length(times),size(X,1),size(X,2));
Vgradfield_Snapshots = zeros(length(times),size(X,1),size(X,2));
for i =1:length(times)
    t = times(i);
    F  = A * exp(-b*t) * sin(kx * X + omega * t);
    dFx = A * exp(-b*t) * kx * cos(kx * X + omega * t);
    Vfield_Snapshots(i,:,:) = F;
    Vgradfield_Snapshots(i,:,:) = dFx;
end
%% 
%Plots the complete solution animation for visualization purposes
MAXVAL = max(abs(Vfield_Snapshots), [], 'all');
MAXGRADVAL = max(abs(Vgradfield_Snapshots), [], 'all');

% Initialize video
close all
clc
myVideo = VideoWriter('simulation_planar_sine_wave.avi'); %open video file
myVideo.FrameRate = 8;  %can adjust this, 5 - 10 works well for me
open(myVideo)

fi=figure('Color','w');
for i=1:length(times)  
    h(1) = subplot(2,2,1);
    surf(Y*L/length(y),X*L/length(x),...
        squeeze(Vfield_Snapshots(i,:,:)));
    caxis([-MAXVAL MAXVAL])
    colormap redblue
    xlabel('y');
    ylabel('x');
    zlabel('height [m]')
    title(titleStr1);
    colorbar;
    xlim([0 L])
    zlim([-2*MAXVAL 2*MAXVAL])
    ylim([0 L])
    set(gca,'ydir','reverse')
%     axis tight

    h(2) = subplot(2,2,3);
    imagesc(y*L/length(y),x*L/length(x),...
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

    h(3) = subplot(2,2,4);
    imagesc(y*L/length(y),x*L/length(x),...
        squeeze(Vgradfield_Snapshots(i,:,:))');
    caxis([-MAXGRADVAL MAXGRADVAL])
    colormap redblue
    xlabel('y');
    ylabel('x');
    title(titleStr2);
    colorbar;
    xlim([0 L])
    ylim([0 L])
    set(gca,'ydir','reverse')
    axis square

    pos = get(h,'Position');
    new = mean(cellfun(@(v)v(1),pos(2:3)));
    set(h(1),'Position',[new,pos{1}(2:end)])
    ax = gcf;
    ax.Position = [49.5000 134.5000 1.2755e+03 675.5000];

    drawnow;
    pause(0.01)    %Pause and grab frame

    frame = getframe(gcf); %get frame
    writeVideo(myVideo, frame);
end
close(myVideo)