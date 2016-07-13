
%% Read input RBG Video | Test example

inputRGBVideo = VideoReader('test_data/WALK.MP4');

% Get the frame of RGB Video and convert each picture to YUV color space
i = 1;
while hasFrame(inputRGBVideo)
    
    % read image frame from original RGB Video
    % save image jpg file to images folder
    img = readFrame(inputRGBVideo);
   
      filename = [sprintf('%03d',i) '.jpg'];
      fullname = fullfile('test_data','images',filename);
      imwrite(img,fullname);
   
      % map jpg image frame from rgb to yuv color space
      yuvImg_pre = rgb2ycbcr(img);
      yuvImg = imadjust(yuvImg_pre(:,:,1));
      yuv_filename = [sprintf('%03d',i) '.jpg'];
      yuv_fullname = fullfile('test_data','yuv_images',yuv_filename);
      imwrite(yuvImg,yuv_fullname);
 
   i = i+1;
end

%%%%%%%%%%%
imshow(imadjust(yuvImg(:,:,1)));

%% extarct green section
for j = 1:1502
    % get the previous and next image
    imageIndexName_prev = [sprintf('%03d',j) '.jpg'];
    img_prev = imread(fullfile('test_data','images',imageIndexName_prev));

    img_prev = double(img_prev);
    [row, col] = size(img);
    dist_img = zeros(row,col);
    
    for i=1:row
        for k=1:col
            dist_img(i,k) = sqrt(double((img_prev(i,k,1)-0)^2 + (img_prev(i,k,2)-255)^2 + (img_prev(i,k,3)-0)^2));
        end
    end
    
    % threshold
    index_green = dist_img < 198; 
        
    final_img = zeros(row,col);
    for i=1:row 
        for k=1:col 
            if index_green(i,k) == 1 
                final_img(i,k)=255; 
            else 
                final_img(i,k)=0; 
            end
        end 
    end
    
    
    imshow(final_img)    
    break;
end
%% Green output test
for iter=298:453

    imageIndexName_prev = [sprintf('%03d',iter) '.jpg'];
    img_prev = imread(fullfile('test_data','images',imageIndexName_prev));

    img_prev = double(img_prev);
    [row, col] = size(img);
    dist_img = zeros(row,col);
    
    for i=1:row
        for k=1:col
            dist_img(i,k) = sqrt(double((img_prev(i,k,1)-0)^2 + (img_prev(i,k,2)-255)^2 + (img_prev(i,k,3)-0)^2));
        end
    end
    
    % threshold
    index_green = dist_img < 198; 
        
    final_img = zeros(row,col);
    for i=1:row 
        for k=1:col 
            if index_green(i,k) == 1 
                final_img(i,k)=255; 
            else 
                final_img(i,k)=0; 
            end
        end 
    end
    seg_filename = [sprintf('%03d',iter) '.jpg'];
    seg_fullname = fullfile('test_data','gre_output',seg_filename);
    imwrite(final_img,seg_fullname);
end


%% data segmentation
count = i-1;
for k=1:count
    
    % get the previous and next image
    imageIndexName_prev = [sprintf('%03d',k) '.jpg'];
    img_prev = imread(fullfile('test_data','yuv_images',imageIndexName_prev));
      
    % write to the file
    [mask,~,~,~]=EMSeg(img_prev,2);

    [row,col] = size(ima); 
    final_img = zeros(row,col); 
    
    for i=1:row 
        for j=1:col 
            if mask(i,j) == 1 
                final_img(i,j)=1; 
            else 
                final_img(i,j)=255; 
            end
        end 
    end
    
    seg_image = final_img/255;
    seg_filename = [sprintf('%03d',k) '.jpg'];
    seg_fullname = fullfile('test_data','seg_images',seg_filename);
    imwrite(seg_image,seg_fullname);
end
%% Pixel difference domain 

count = 1227;
for i=1:count
   
   % get the previous and next image
   imageIndexName_prev = [sprintf('%03d',i) '.jpg'];
   imageIndexName_next = [sprintf('%03d',i+1) '.jpg'];
   img_prev = double(imread(fullfile('test_data','yuv_images',imageIndexName_prev)));
   img_next = double(imread(fullfile('test_data','yuv_images',imageIndexName_next)));
   
   % write to the file
   diff_image = abs(img_next-img_prev);
   [row, col] = size(diff_image);
   diff_index = diff_image >= 18;
   result_img = zeros(row, col);
   result_img(diff_index) = diff_image(diff_index);
 
   gpu_img = gpuArray(result_img);
   result_img = gather(medfilt2(gpu_img, [3 3]));
   
   diff_filename = [sprintf('%03d',i) '.jpg'];
   diff_fullname = fullfile('test_data','diff_medfilt',diff_filename);
   imwrite(result_img,diff_fullname);
   
   fprintf('%d\n', i);
end


%% Data Segmentation | Edge detection
i = 1;

for i = 1:4:30
    imageIndexName_prev = [sprintf('%03d',i) '.jpg'];
    imageIndexName_next = [sprintf('%03d',i+4) '.jpg'];
    img_prev = imread(fullfile('test_data','yuv_images',imageIndexName_prev));
    img_next = imread(fullfile('test_data','yuv_images',imageIndexName_next));

    % write to the file
   diff_image = imadjust(img_next-img_prev);
   diff_filename = [sprintf('%03d',i) '.jpg'];
   diff_fullname = fullfile('test_data','diff_test_images',diff_filename);
   imwrite(diff_image,diff_fullname);
end
%%
i = 128; 
imageIndexName_next = [sprintf('%03d',i) '.jpg'];
img_next = imread(fullfile('test_data','yuv_images',imageIndexName_next));
figure;
imshow(img_next);

ima= img_next;
k = 2;
[mask,mu,v,p]=EMSeg(ima,k)

[row col] = size(ima); 
final_img = zeros(row,col); 
for i=1:row 
    for j=1:col 
        if mask(i,j)==1 
            final_img(i,j)=1; 
        else 
            final_img(i,j)=255; 
        end 
    end 
end 
figure;

imshow(final_img/255); 



%% Create output video file from processes image frames

imageNames = dir(fullfile('test_data','diff_images','*.jpg'));
imageNames = {imageNames.name}';

outputVideo = VideoWriter(fullfile('test_data/output','diff_test.avi'));
outputVideo.FrameRate = inputRGBVideo.FrameRate;
open(outputVideo)

%for i = 1:length(imageNames)
for i = 1:1005

   imageIndexName = [sprintf('%03d',i) '.jpg'];
   %img = imread(fullfile('test_data','yuv_images',imageNames{i}));
   img = imread(fullfile('test_data','diff_images',imageIndexName));
   writeVideo(outputVideo,img)
end

close(outputVideo)

%% binary data segmentation

mask = false(size(test_img));
mask(540,960) = true;
W = graydiffweight(test_img, mask, 'GrayDifferenceCutoff', 25);
thresh = 0.01;
[BW, D] = imsegfmm(W, mask, thresh);
figure
imshow(BW);
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
I = img;
BW1 = edge(I);
BW2 = edge(I,'canny');
figure;
imshowpair(BW1,BW2,'montage')
title('Sobel Filter                                   Canny Filter');

%% graph the white intensity over frame

count = 1227;
S = zeros(1,count);
for i=1:count
   
   % get the previous and next image
   imageIndexName_curr = [sprintf('%03d',i) '.jpg'];
   img_curr = double(imread(fullfile('test_data','diff_threshold',imageIndexName_curr)));
   %img = clear_noise(img_curr);
   S(i) = sum(sum(img_curr));
  
   
end 

figure
x = 1:size(S, 2);
plot (x, S);
hold on;
plot ([1, count], [S(1), S(count)],'r^');
hold off;
axis tight;
ylabel('White Intensity');
xlabel('Time elapsed in 1 frame');
title('Gait Test Event Intensty Over Time');
   
   