%% File to process the final mapped images to the Stokes Vector Space
% the result is the same shape as the final_map: the intensitu map for
% the first, second and third cameras in that order (left to right)
% The resultant also has the third dimension as =3, for the first component
% being the first Stokes parameter S0, second being S1 and third being S3
%% variable Analyzer Matrix
load('C:\Users\tracy\Downloads\saksham_polarimetric_cam\analyzerMatrix.mat')
% load('C:\Users\tracy\Downloads\saksham_polarimetric_cam\analyzerMatrix_single_for_all.mat')
load('C:\Users\tracy\Downloads\saksham_polarimetric_cam\final_map.mat')
final_map = new_map;

%smooth the px to px intensity variation
% fun = @(x) mean(x(:));
% final_map(:,:,1)= nlfilter(final_map(:,:,1),[3 3],fun); 
% final_map(:,:,2)= nlfilter(final_map(:,:,2),[3 3],fun);
% final_map(:,:,3)= nlfilter(final_map(:,:,3),[3 3],fun);
% show smoothed images
figure(2); subplot(1,3,1); imshow(final_map(:,:,1)); subplot(1,3,2); 
imshow(final_map(:,:,2)); subplot(1,3,3); imshow(final_map(:,:,3));

final_S_map = zeros(size(final_map));
for i = 1:1:size(final_map,1)
    for j= 1:1:size(final_map,2)
        for x =1:1:size(final_map,4)
            final_S_map(i,j,:,x) = ...
                reshape(analyzerMatrices(i,j,:,:), [3,3]) * ...
                double(reshape(final_map(i,j,:,x),3,1));
        end
    end
end
%% variable px o px Analyzer Matrix
% load('C:\Users\tracy\Downloads\saksham_polarimetric_cam\analyzerMatrix.mat')
% load('C:\Users\tracy\Downloads\saksham_polarimetric_cam\final_map.mat')
% final_S_map = zeros(size(final_map));
% for i = 1:1:size(final_map,1)
%     for j= 1:1:size(final_map,2)
%         for x =1:1:size(final_map,4)
%             final_S_map(i,j,:,x) = ...
%                 reshape(analyzerMatrices(i,j,:,:), [3,3]) * ...
%                 double(reshape(final_map(i,j,:,x),3,1));
%         end
%     end
% end
%% save the Stokes parameter map
save('C:\Users\tracy\Downloads\saksham_polarimetric_cam\final_S_map.mat', 'final_S_map', '-v7.3', '-nocompression')