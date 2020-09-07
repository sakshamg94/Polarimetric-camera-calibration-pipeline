load('C:\Users\tracy\Downloads\saksham_polarimetric_cam\aolp_phi.mat')
load('C:\Users\tracy\Downloads\saksham_polarimetric_cam\dolp_theta.mat')
%%
X = -cos(phi).*theta;
Y = sin(phi).*theta;

sx = tan(X);
sy = tan(Y);
%%
t=1;
figure;
subplot(2,2,1);
contourf(X(:,:,t),3);colorbar();
title('X = -cos(\phi).*\theta')
subplot(2,2,2);
contourf(Y(:,:,t),3); colorbar();
title('Y = sin(\phi).*\theta')

subplot(2,2,3);
contourf(sx(:,:,t),3); colorbar();
title('Slope_x = tan(X)')
subplot(2,2,4);
contourf(sy(:,:,t),3); colorbar();
title('Slope_y = tan(Y)')
