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
phi = dolp + pi/2;
%% save
save('C:\Users\tracy\Downloads\saksham_polarimetric_cam\aolp_phi.mat','aolp','phi')
%% plot
x = 1:1:size(final_S_map,2);
y = 1:1:size(final_S_map,1);
[X,Y] = meshgrid(x,y);


v = VideoWriter('C:\Users\tracy\Downloads\saksham_polarimetric_cam\aolp.avi');
open(v);
for t = 1:3:30
   t
   figure(1);
   contourf(X,Y,phi(:,:,t), 3);
   colorbar();
   frame = getframe(gcf);
   writeVideo(v,frame);
end

close(v);
