%% Solve for AOLP
load('C:\Users\tracy\Downloads\saksham_polarimetric_cam\final_S_map.mat')
cols = size(final_S_map,2);
gamma = 2*ones(1, cols);
cx = cols/2;%cameraParams.PrincipalPoint(1);
fx = cameraParams.FocalLength(1);
aolp = zeros(size(final_S_map,1),size(final_S_map,2),size(final_S_map,4));
for i = 1:1:size(final_S_map,1)
    for j= 1:1:size(final_S_map,2)
%         gamma(j) = atan(abs((cx-j))/fx)*180/pi; 
        for x =1:1:size(final_S_map,4)
            S2 = final_S_map(i,j,3,x);
            S1 = final_S_map(i,j,2,x);
            aolp(i,j,x) = ...
                0.5*atan((S2*cosd(2*gamma(j)) - S1*sind(2*gamma(j)))...
                /(S1*cosd(2*gamma(j)) + S2*sind(2*gamma(j))));
        end
    end
end
phi = (aolp + pi/2)*180/pi;
%%
figure;
imshow(uint8(phi)); hold on; 
title('projected surface orientation (degrees)')

figure(47)
Xd = 1:1:size(aolp(:,:,1),2);
Yd = 1:1:size(aolp(:,:,1),1);
surf(Xd, Yd, imgaussfilt(uint8(phi), 1))
title('projected surface orientation (degrees)')

%% save
save('C:\Users\tracy\Downloads\saksham_polarimetric_cam\aolp_phi.mat','aolp','phi')
%% plot
% x = 1:1:size(final_S_map,2);
% y = 1:1:size(final_S_map,1);
% [X,Y] = meshgrid(x,y);
% 
% 
% v = VideoWriter('C:\Users\tracy\Downloads\saksham_polarimetric_cam\aolp.avi');
% open(v);
% for t = 1:3:30
%    t
%    figure(1);
%    contourf(X,Y,phi(:,:,t), 3);
%    colorbar();
%    frame = getframe(gcf);
%    writeVideo(v,frame);
% end
% 
% close(v);
