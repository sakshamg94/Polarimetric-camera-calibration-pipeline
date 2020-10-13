load('C:\Users\tracy\Downloads\saksham_polarimetric_cam\aolp_phi.mat')
load('C:\Users\tracy\Downloads\saksham_polarimetric_cam\dolp_theta.mat')
%%
X1 = -cos(phi*pi/180).*theta*pi/180;
Y1 = sin(phi*pi/180).*theta*pi/180;
X2 = phi*pi/180;
Y2 = theta*pi/180;

sx1 = tan(X1);
sy1 = tan(Y1);
sx2 = tan(X2);
sx2(sx2>50)= nan;
sx2(sx2<-50)= nan;
sy2 = tan(Y2);
%%
t=1;
slicec = 156:640; 
slicer = 326:689;
slicet = 1;
figure;
subplot(3,3,1);
contourf(sx1(slicer,slicec,slicet),3);colorbar();
title('Slope_x = tan[-cos(\phi).*\theta]')
set(gca, 'YDir','reverse')
subplot(3,2,2);
contourf(sy1(slicer,slicec,slicet),3); colorbar();
title('Slope_y = tan[sin(\phi).*\theta]')
set(gca, 'YDir','reverse')

subplot(3,2,3);
contourf(sx2(slicer,slicec,slicet),3); colorbar();
title('Slope_x = tan[\phi]')
set(gca, 'YDir','reverse')
subplot(3,2,4);
contourf(sy2(slicer,slicec,slicet),3); colorbar();
title('Slope_y = tan[\theta]')
set(gca, 'YDir','reverse')

subplot(3,2,5);
contourf(X2(slicer,slicec,slicet)*180/pi,3); colorbar();
title('\phi')
set(gca, 'YDir','reverse')
subplot(3,2,6);
contourf(Y2(slicer,slicec,slicet)*180/pi,3); colorbar();
title('\theta')
set(gca, 'YDir','reverse')