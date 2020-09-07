%% Solve for DOLP & theta_i
% load('C:\Users\tracy\Downloads\saksham_polarimetric_cam\final_S_map.mat')
%%
ni = 1;
nt = 1.58;%1.333; 57.68 for EMG 905
thI = linspace(0.0000001, atan(nt/ni), 200);
thT = asin(ni*sin(thI)/nt);

alpha = 0.5*(tan(thI-thT)./tan(thI+thT)).^2;
eta = 0.5*(sin(thI-thT)./sin(thI+thT)).^2;

DOLP = abs((alpha - eta)./(alpha + eta));
figure;
plot(thI*180/pi, DOLP)
%% Calculate DOLP and invert to get angle of incidence
dolp = zeros(size(final_S_map,1),size(final_S_map,2),size(final_S_map,4));
theta = zeros(size(final_S_map,1),size(final_S_map,2),size(final_S_map,4));

for i = 1:1:size(final_S_map,1)
    for j= 1:1:size(final_S_map,2)
        for x =1
            dolp(i,j,x) = ...
                sqrt(final_S_map(i,j,2)^2 + ...
                final_S_map(i,j,3)^2)/final_S_map(i,j,1);
            theta(i,j,x) = interp1(DOLP,thI,dolp(i,j,x))*180/pi; % in degrees
        end
    end
end
%% save
save('C:\Users\tracy\Downloads\saksham_polarimetric_cam\dolp_theta.mat','dolp','theta', '-v7.3')
%% plot
% load('../dolp_theta.mat')
% load('../final_S_map.mat')
x = 1:1:size(final_S_map,2);
y = 1:1:size(final_S_map,1);
[X,Y] = meshgrid(x,y);


v = VideoWriter('C:\Users\tracy\Downloads\saksham_polarimetric_cam\dolp.avi');
open(v);
figure();
for t = 1:3:30
   t
   contourf(X,Y,theta(:,:,t), 2);
   colorbar();
   frame = getframe(gcf);
   writeVideo(v,frame);
end

close(v);


