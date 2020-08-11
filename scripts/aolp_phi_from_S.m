%% Solve for AOLP
% load('../final_S_map.mat')
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
save('../aolp_phi.mat','aolp','phi')
%% plot
x = 1:1:size(final_S_map,2);
y = 1:1:size(final_S_map,1);
[X,Y] = meshgrid(x,y);


v = VideoWriter('aolp.avi');
open(v);
for t = 1:1:20
   t
   contourf(X,Y,phi(:,:,t));
   colorbar();
   frame = getframe(gcf);
   writeVideo(v,frame);
end

close(v);
