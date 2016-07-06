
%% Read input RBG Video | Test example

inputRGBVideo = VideoReader('test_data/MAH00052.MP4');

% Get the frame of RGB Video and convert each picture to YUV color space
i = 1;
while hasFrame(inputRGBVideo)
    
   % read image frame from original RGB Video
   % save image jpg file to images folder
   img = readFrame(inputRGBVideo);
   filename = [sprintf('%03d',i) '.jpg'];
   fullname = fullfile('test_data','images',filename);
   imwrite(img,fullname)
   
   % map jpg image frame from rgb to yuv color space
   yuvImg = rgb2ycbcr(img);
   yuv_filename = [sprintf('%03d',i) '.jpg'];
   yuv_fullname = fullfile('test_data','yuv_images',yuv_filename);
   imwrite(yuvImg,yuv_fullname)
   
   i = i+1;
end

%% Data Segmentation 




%% Create output video file from processes image frames

imageNames = dir(fullfile('test_data','yuv_images','*.jpg'));
imageNames = {imageNames.name}';

outputVideo = VideoWriter(fullfile('test_data/output','yuv_test.avi'));
outputVideo.FrameRate = inputRGBVideo.FrameRate;
open(outputVideo)

%for i = 1:length(imageNames)
for i = 1:1432

   imageIndexName = [sprintf('%03d',i) '.jpg'];
   %img = imread(fullfile('test_data','yuv_images',imageNames{i}));
   img = imread(fullfile('test_data','yuv_images',imageIndexName));
   writeVideo(outputVideo,img)
end

close(outputVideo)

%% binary data segmentation

test_img = imread(fullfile('test_data','yuv_images','1000.jpg'));
imshow(test_img)
mask = false(size(test_img));
mask(540,960) = true;
test_img
W = graydiffweight(test_img, mask, 'GrayDifferenceCutoff', 25);
thresh = 0.01;
[BW, D] = imsegfmm(W, mask, thresh);
figure
imshow(BW)
title('Segmented Image')

%% Edge Detection
img1 = imread(fullfile('test_data','yuv_images','1003.jpg'));
img2 = imread(fullfile('test_data','yuv_images','990.jpg'));
%%
%I = imgg(:,:,1);
yuvImg1 = rgb2ycbcr(img1);
yuvImg2 = rgb2ycbcr(img2);

diff = yuvImg1-yuvImg2;
diff2 = img1- img2;
imshow(diff2);

%% 
BW1 = edge(I);
BW2 = edge(I,'canny');
figure;
imshowpair(BW1,BW2,'montage')
title('Sobel Filter                                   Canny Filter');