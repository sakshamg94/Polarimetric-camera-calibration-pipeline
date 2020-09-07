% show the 3 raw images
figure(2); subplot(1,3,1); imshow(Cam_1_Image1); subplot(1,3,2); 
imshow(Cam_2_Image1); subplot(1,3,3); imshow(Cam_3_Image1);

% show the mapped left and right camera images (more precisely, their 
% differences from the center image)
% you indeed get black pixels for the location of the ferrofluid
correct_img = imwarp(Cam_3_Image1,tRC,'OutputView',Rfixed);
a = Cam_2_Image1-correct_img;
imshow(a);

correct_img = imwarp(Cam_1_Image1,tLC,'OutputView',Rfixed);
b = Cam_2_Image1-correct_img;
imshow(b);

% here too -- no problem with cropping -- diff image is all ~0s except for
% specularly saturated parts like the vertical edges of the petridish
correct_img = imwarp(Cam_1_Image1,tLC,'OutputView',Rfixed);
b = Cam_2_Image1(top+1:1026-bot, left+1:1282-right)- correct_img(top+1:1026-bot, left+1:1282-right);
imshow(b)

% show the differences to make sure all is good
close all
correct_img = imwarp(Cam_1_Image1,tLC,'OutputView',Rfixed);
correct_img = correct_img(top+1:1026-bot, left+1:1282-right);
b = Cam_2_Image1(top+1:1026-bot, left+1:1282-right)- correct_img;
imshow(b)

close all
c = final_map(:,:,2) - final_map(:,:,1) ;
imshow(c)

isequal(b,c)
 
%%%% note that final_map(:,:,2)-final_map(:,:,3) is different image from
%%%% final_map(:,:,3) - final_map(:,:,2) because of flooring in differences
%%%% takn on uint8 objects
close all
correct_img = imwarp(Cam_3_Image1,tRC,'OutputView',Rfixed);
correct_img = correct_img(top+1:1026-bot, left+1:1282-right);
b = Cam_2_Image1(top+1:1026-bot, left+1:1282-right)- correct_img;
imshow(b)

close all
c = final_map(:,:,2) - final_map(:,:,3) ;
imshow(c)

isequal(b,c)

%% show the S map 3 channels separately
figure(2); subplot(1,3,1); imshow(final_S_map(:,:,1)); subplot(1,3,2); 
imshow(final_S_map(:,:,2)); subplot(1,3,3); imshow(final_S_map(:,:,3));

%% show teh dolp, aolp maps
imshow(aolp(:,:,1))
imshow(theta(:,:,1))
imshow(dolp(:,:,1))

%%
fun = @(x) mean(x(:));
B = nlfilter(dolp(:,:,1),[2 2],fun); 
montage({dolp(:,:,1), B})