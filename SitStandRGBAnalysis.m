%% Script for analyzing the Sit-Stand Test RGB Video
%% Reading the Input RGB Video


inputRGBVideo = VideoReader('test_data/MAH00174.MP4');

path_save_dir = 'temp';

% Create folders to hold the processed fils
path_diff_threshold = 'diff_threshold';
path_diff_mf_threshold1 = 'diff_mf_threshold1';
path_diff_mf_threshold2 = 'diff_mf_threshold2';
path_diff_mf_threshold3 = 'diff_mf_threshold3';
path_yuv_images = 'yuv_images';
path_images_dir = 'images';

mkdir(path_save_dir);
mkdir(path_images_dir);
mkdir(path_yuv_images);

fprintf('Reading Input Video and Computing frames in yuv Y-channel.\n') ;

% Get the frame of RGB Video and convert each picture to YUV color space

%%%%%%%%%%%%%%%%%%%%% Get Y channel of YUV image frames starts %%%%%%%%%%%%%%%%%%%
i = 1;
while hasFrame(inputRGBVideo)
    
    % read image frame from original RGB Video
    % save image jpg file to images folder
    img = readFrame(inputRGBVideo);
   
    filename = [sprintf('%03d',i) '.jpg'];
    fullname = fullfile(path_save_dir,path_images_dir,filename);
    imwrite(img,fullname);

    % map jpg image frame from rgb to yuv color space
    % get Y channal of yuv domain
    yuvImg_pre = rgb2ycbcr(img);
    yuvImg = imadjust(yuvImg_pre(:,:,1));

    % Hardcoding research assistant away
    yuvImg(:, 1400:1920) = 0;
    yuvImg(:, 1:830) = 0;

    yuv_filename = [sprintf('%03d',i) '.jpg'];
    yuv_fullname = fullfile(path_save_dir, path_yuv_images,yuv_filename);
    imwrite(yuvImg,yuv_fullname);
    i = i+1;
end
%%%%%%%%%%%%%%%%%%% Get Y channel of YUV image frames ends %%%%%%%%%%%%%%%%%%%

%% Get the pixel difference images with individual and area threshold

fprintf('Computing Pixel Difference Image.\n') ;

%==================== Compute Pixel Difference Image starts ===================
frame_count = i - 2;
for i=1:frame_count
   
   % get the previous and next image | diff_images - "diff"
   imageIndexName_prev = [sprintf('%03d',i) '.jpg'];
   imageIndexName_next = [sprintf('%03d',i+1) '.jpg'];
   img_prev = double(imread(fullfile(path_save_dir,path_yuv_images,imageIndexName_prev)));
   img_next = double(imread(fullfile(path_save_dir,path_yuv_images,imageIndexName_next)));
   
   % Pixel difference threshold
   diff_image = abs(img_next-img_prev);
   [row, col] = size(diff_image);
   diff_index = diff_image >= 18;
   result_img = zeros(row, col);
   result_img(diff_index) = diff_image(diff_index);
  
   % write to the file | diff_threshold2 - "diff_threshold"
   diff_filename2 = [sprintf('%03d',i) '.jpg'];
   diff_fullname2 = fullfile(path_save_dir,path_diff_threshold,diff_filename2);
   imwrite(result_img,diff_fullname2);
   
end
%==================== Compute Pixel Difference Image ends ====================


% Clear the noise in images with medium filter

%~~~~~~~~~~~~~~~ Apply medium filter on spacital domain starts ~~~~~~~~~~~~~~~~~
for i=1:frame_count
   
   % Read images from files
   imageIndexName = [sprintf('%03d',i) '.jpg'];
   img = double(imread(fullfile(path_save_dir,path_diff_threshold,imageIndexName)));
   
   % Use medium filter to clean the noise
   img_mf = medfilt2(img, [3 3]);
   
   % Save processed frames to file
   diff_filename = [sprintf('%03d',i) '.jpg'];
   diff_fullname = fullfile(path_save_dir,path_diff_mf_threshold1,diff_filename);
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
    img_stack = double(imread(fullfile(path_save_dir,path_diff_mf_threshold2,imageIndexName1)));

    for iter2=2:15
        i = i+1;
        imageIndexName = [sprintf('%03d',i) '.jpg'];
        img = double(imread(fullfile(path_save_dir,path_diff_mf_threshold2,imageIndexName)));
        img_stack = cat(3, img_stack, img);
    end
       
    % Use medium filter to clean the noise
    B = medfilt3(img_stack,[3 3 3]);  
   
    % Write image frames to file
    i = i-15;
    for iter2=1:15
        i = i+1;
        diff_filename = [sprintf('%03d',i) '.jpg'];
        diff_fullname = fullfile(path_save_dir,path_diff_mf_threshold3,diff_filename);
        imwrite(uint8(B(:,:,iter2)),diff_fullname);
    end
end
%=%=%=%=%=%=%=%= Apply medium filter on time domain ends %=%=%=%=%=%=%=%=%=%=

%% graph the white intensity over frame
 
count = i;
S = zeros(1,count);
for i=1:count
    imageIndexName = [sprintf('%03d',i) '.jpg'];
    img_curr = double(imread(fullfile(path_save_dir,path_diff_mf_threshold3,imageIndexName)));
    S(i) = sum(sum(img_curr));
end
 

figure;
S_smooth = smooth(S);
x = 1:size(S_smooth, 1);
plot (x, S_smooth);
hold on;
plot ([1, count], [S_smooth(1), S_smooth(count)],'r^');
hold off;
axis tight;
ylabel('White Intensity');
xlabel('Time elapsed in 1 frame');
title('SitStand Test Event Intensty Over Time');

%% Calculate the midpoint of the box around the person

%~%~%~%~%~%~%~%~%~%~%~%~%~%~% Box bounding algorithm starts %~%~%~%~%~%~%~%~%~%~%~%%~%~%~%~~
leng = zeros(1, count);
for itera=1:count

    imageIndexName = [sprintf('%03d',itera) '.jpg'];
    img = double(imread(fullfile(path_save_dir,path_diff_mf_threshold3,imageIndexName)));

    thresholdValue = 240;

    line([thresholdValue, thresholdValue], ylim, 'Color', 'r');
    img = imfill(img);
    
    vertical_sum = sum(img,2);
     
    % Find the start_index and end_index of horizontal_sum
    peak_threshold = 500;
    vertical_start_index = 1;
    for i=1:length(vertical_sum)-1 % Loop through vector intensityOverTime - 1 to avoid accessing past the vector
        difference=abs(vertical_sum(i+1)-vertical_sum(i)); % calculate difference between neighboring intensities        
        if difference > peak_threshold % If statement to determine start time index
            vertical_start_index=i;
            i;
            break;
        end
    end

    peak_threshold_rev = 500;
    vertical_stop_index = 1;

    for i=length(vertical_sum):-1:2 % Loop through vector intensityOverTime - 1 to avoid accessing past the vector
        difference = abs(vertical_sum(i)-vertical_sum(i-1)); % calculate difference between neighboring intensities
        if difference > peak_threshold_rev  % If statement to determine start time index
            vertical_stop_index=i;
            break;
        end
    end
    
    %midpoint = vertical_stop_index - vertical_start_index;
    midpoint = vertical_start_index;
    leng(itera) = midpoint;
end
%~%~%~%~%~%~%~%~%~%~%~%~%~%~% Box bounding algorithm ends %~%~%~%~%~%~%~%~%~%~%~%%~%~%~%~~

leng_smooth = smooth(leng,15);

figure;
x = 1:size(leng_smooth, 1);
plot (x, leng_smooth);
hold on;
plot ([1, count], [leng_smooth(1), leng_smooth(count)],'r^');
hold off;
axis tight;
ylabel('Y-coordinate of midpoint');
xlabel('Time elapsed in 1 frame');
title('SitStand Test Event Intensty Over Time');

% leng_smooth(leng_smooth > 400) = 0; 

fprintf('Computing the time stamp for each Sit-Stand Cycle.\n') ;

% Find the maxima and minima point
[Maxima,MaxIdx] = findpeaks(leng_smooth, 'MinPeakDistance', 30, 'MinPeakHeight',250);
DataInv = 1.01*max(leng_smooth) - leng_smooth;
[Minima,MinIdx] = findpeaks(DataInv, 'MinPeakHeight', 200, 'MinPeakDistance', 30);

Maxima = leng_smooth(MaxIdx);

if length(Maxima) > 6
    idx = find(Maxima == max(Maxima),1,'first');
    MaxIdx(idx) = [];
end

if length(Minima) > 5 
    idx = find(leng_smooth(MinIdx) == min(leng_smooth(MinIdx)),1,'first');
    MinIdx(idx) = [];
end

figure;
x = 1:size(leng_smooth, 1);
plot (x, leng_smooth);
hold on;
plot(MinIdx, leng_smooth(MinIdx),'r^');
plot(MaxIdx, leng_smooth(MaxIdx),'b^');
hold off;
axis tight;

% Print out the time stamp table for SitStand Test 

timeStamp = MaxIdx;

SitStandCount = {'1','2','3','4','5'};
T = table;
T.SitStandCount = SitStandCount';
T.Start = timeStamp(1:5);
T.Stop = timeStamp(2:6);
T

SitStandCycle = timeStamp(2:6) - timeStamp(1:5);
fprintf('Sit Stand Cycle Duration in frames: \n');
disp(SitStandCycle);
fprintf('Sit Stand Cycle Duration in seconds: \n') ;
disp(SitStandCycle/30);

figure;
x = 1:length(SitStandCycle);
plot (x, SitStandCycle/30);
ylabel('Sit-Stand Cycle Duration');
xlabel('Sit-Stand Count');
axis([1 5 1 2])
