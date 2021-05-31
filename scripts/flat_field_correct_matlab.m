img = imread('multiglass2_40DegCam_BackscatterLightCardboard_AmbientLightOff_IM0.tiff');
imshow(img)
corrected = imflatfield(img, 20);
%%
figure(2);
imshow(corrected)