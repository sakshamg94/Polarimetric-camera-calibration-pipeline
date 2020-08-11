%% Solve for DOLP & theta_i
% load('../final_S_map.mat')
%%
ni = 1;
nt = 1.333;
thI = linspace(0.0000001, 53*pi/180, 200);
thT = asin(ni*sin(thI)/nt);

alpha = 0.5*(tan(thI-thT)./tan(thI+thT)).^2;
eta = 0.5*(sin(thI-thT)./sin(thI+thT)).^2;

DOLP = abs((alpha - eta)./(alpha + eta));
figure;
plot(thI, DOLP)
%% Calculate DOLP and invert to get angle of incidence
dolp = zeros(size(final_S_map,1),size(final_S_map,2),size(final_S_map,4));
theta = zeros(size(final_S_map,1),size(final_S_map,2),size(final_S_map,4));

for i = 1:1:size(final_S_map,1)
    for j= 1:1:size(final_S_map,2)
        for x =1:1:size(final_S_map,4)
            dolp(i,j,x) = ...
                sqrt(final_S_map(i,j,2)^2 + ...
                final_S_map(i,j,3)^2)/final_S_map(i,j,1);
            theta(i,j,x) = interp1(DOLP,thI,dolp(i,j,x))*180/pi; % in degrees
        end
    end
end
%% save
save('../dolp_theta.mat','dolp','theta', '-v7.3')
%% plot
x = 1:1:size(final_S_map,2);
y = 1:1:size(final_S_map,1);
[X,Y] = meshgrid(x,y);


v = VideoWriter('dolp.avi');
open(v);
for t = 1:1:20
   t
   contourf(X,Y,theta(:,:,t));
   colorbar();
   frame = getframe(gcf);
   writeVideo(v,frame);
end

close(v);


