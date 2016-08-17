%% Script for analyzing the Balance Test RGB Video
%% Reading the Input RGB Video

inputRGBVideo = VideoReader('test_data3/Balance.mp4');

fprintf('Reading Input Video and Computing frames in yuv Y-channel.\n') ;

% Get the frame of RGB Video and convert each picture to YUV color space

%%%%%%%%%%%%%%%%%%%%% Get Y channel of YUV image frames starts %%%%%%%%%%%%%%%%%%%
i = 1;
while hasFrame(inputRGBVideo)
    
    % read image frame from original RGB Video
    % save image jpg file to images folder
    img = readFrame(inputRGBVideo);
   
    filename = [sprintf('%03d',i) '.jpg'];
    fullname = fullfile('test_data3','images4',filename);
    imwrite(img,fullname);

    % map jpg image frame from rgb to yuv color space
    % get Y channal of yuv domain
    yuvImg_pre = rgb2ycbcr(img);
    yuvImg = imadjust(yuvImg_pre(:,:,1));

    % Hardcoding research assistant away
    yuvImg(:, 1400:1920) = 0;
    yuvImg(:, 1:830) = 0;

    yuv_filename = [sprintf('%03d',i) '.jpg'];
    yuv_fullname = fullfile('test_data3','yuv_images4',yuv_filename);
    imwrite(yuvImg,yuv_fullname);
    i = i+1;
end
%%%%%%%%%%%%%%%%%%%%% Get Y channel of YUV image frames ends %%%%%%%%%%%%%%%%%%%

%% Get the pixel difference images with individual and area threshold

fprintf('Computing Pixel Difference Image.\n') ;

%==================== Compute Pixel Difference Image starts ===================
frame_count = i - 2;
for i=1:frame_count
   
   % get the previous and next image | diff_images - "diff"
   imageIndexName_prev = [sprintf('%03d',i) '.jpg'];
   imageIndexName_next = [sprintf('%03d',i+1) '.jpg'];
   img_prev = double(imread(fullfile('test_data3','yuv_images4',imageIndexName_prev)));
   img_next = double(imread(fullfile('test_data3','yuv_images4',imageIndexName_next)));
   
   % Pixel difference threshold
   diff_image = abs(img_next-img_prev);
   [row, col] = size(diff_image);
   diff_index = diff_image >= 18;
   result_img = zeros(row, col);
   result_img(diff_index) = diff_image(diff_index);
  
   % write to the file | diff_threshold2 - "diff_threshold"
   diff_filename2 = [sprintf('%03d',i) '.jpg'];
   diff_fullname2 = fullfile('test_data3','diff_threshold4',diff_filename2);
   imwrite(result_img,diff_fullname2);   
end
%==================== Compute Pixel Difference Image ends ===================


% Clear the noise in images with medium filter   

%~~~~~~~~~~~~~~~ Apply medium filter on spacital domain starts ~~~~~~~~~~~~~~~~~
for i=1:frame_count
   
   % Read images from files
   imageIndexName = [sprintf('%03d',i) '.jpg'];
   img = double(imread(fullfile('test_data3','diff_threshold4',imageIndexName)));
   
   % Use medium filter to clean the noise
   img_mf = medfilt2(img, [3 3]);
   
   % Save processed frames to file
   diff_filename = [sprintf('%03d',i) '.jpg'];
   diff_fullname = fullfile('test_data3','diff_mf_threshold2222',diff_filename);
   imwrite(uint8(img_mf),diff_fullname);

end
%~~~~~~~~~~~~~~~ Apply medium filter on spacital domain ends ~~~~~~~~~~~~~~~~~


%% Apply median filter in time dimension

%=%=%=%=%=%=%=%= Apply medium filter on time domain starts %=%=%=%=%=%=%=%=%=%=
count_3d = uint32(frame_count/15);
i = 0;
for iter=1:count_3d
    
    % Stack 15 frames for one time and apply 3D medium filter with 3 by 3
    % box
    i = i+1;
    imageIndexName1 = [sprintf('%03d',i) '.jpg'];
    img_stack = double(imread(fullfile('test_data3','diff_mf_threshold2222',imageIndexName1)));

    for iter2=2:15
        i = i+1;
        imageIndexName = [sprintf('%03d',i) '.jpg'];
        img = double(imread(fullfile('test_data3','diff_mf_threshold2222',imageIndexName)));
        img_stack = cat(3, img_stack, img);
    end
       
    % Use medium filter to clean the noise
    B = medfilt3(img_stack,[3 3 3]);  
   
    % Write image frames to file
    i = i-15;
    for iter2=1:15
        i = i+1;
        diff_filename = [sprintf('%03d',i) '.jpg'];
        diff_fullname = fullfile('test_data3','diff_mf_threshold3333',diff_filename);
        imwrite(uint8(B(:,:,iter2)),diff_fullname);
    end
end
%=%=%=%=%=%=%=%= Apply medium filter on time domain ends %=%=%=%=%=%=%=%=%=%=

%% Get the white intensity over frames
 
count = i;
S = zeros(1,count);
for i=1:count
    imageIndexName = [sprintf('%03d',i) '.jpg'];
    img_curr = double(imread(fullfile('test_data3','diff_mf_threshold333',imageIndexName)));
    S(i) = sum(sum(img_curr));
end



