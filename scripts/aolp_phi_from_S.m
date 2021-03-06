%% Solve for AOLP
% load('C:\Users\tracy\Downloads\saksham_polarimetric_cam\final_S_map.mat')
aolp = zeros(size(final_S_map,1),size(final_S_map,2),size(final_S_map,4));
for i = 1:1:size(final_S_map,1)
    for j= 1:1:size(final_S_map,2)
        for x =1:1:size(final_S_map,4)
            aolp(i,j,x) = ...
                0.5*atan(final_S_map(i,j,3,x)/final_S_map(i,j,2,x));
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
