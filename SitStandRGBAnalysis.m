%% Script for analyzing the Sit-Stand Test RGB Video
%% Reading the Input RGB Video

inputRGBVideo = VideoReader('test_data2/SitStand5.mp4');

fprintf('Reading Input Video and Computing frames in yuv Y-channel.\n') ;

% Get the frame of RGB Video and convert each picture to YUV color space
i = 1;
while hasFrame(inputRGBVideo)
    
    % read image frame from original RGB Video
    % save image jpg file to images folder
    img = readFrame(inputRGBVideo);
   
    filename = [sprintf('%03d',i) '.jpg'];
    fullname = fullfile('test_data2','images4',filename);
    imwrite(img,fullname);

    % map jpg image frame from rgb to yuv color space
    % get Y channal of yuv domain
    yuvImg_pre = rgb2ycbcr(img);
    yuvImg = imadjust(yuvImg_pre(:,:,1));

    % Hardcoding research assistant away
    yuvImg(:, 1400:1920) = 0;
    yuvImg(:, 1:830) = 0;

    yuv_filename = [sprintf('%03d',i) '.jpg'];
    yuv_fullname = fullfile('test_data2','yuv_images4',yuv_filename);
    imwrite(yuvImg,yuv_fullname);
    i = i+1;
end

%% Get the pixel difference images with individual and area threshold

fprintf('Computing Pixel Difference Image.\n') ;

frame_count = i - 2;
for i=1:frame_count
   
   % get the previous and next image | diff_images - "diff"
   imageIndexName_prev = [sprintf('%03d',i) '.jpg'];
   imageIndexName_next = [sprintf('%03d',i+1) '.jpg'];
   img_prev = double(imread(fullfile('test_data2','yuv_images4',imageIndexName_prev)));
   img_next = double(imread(fullfile('test_data2','yuv_images4',imageIndexName_next)));
   
   % Pixel difference threshold
   diff_image = abs(img_next-img_prev);
   [row, col] = size(diff_image);
   diff_index = diff_image >= 18;
   result_img = zeros(row, col);
   result_img(diff_index) = diff_image(diff_index);
  
   % write to the file | diff_threshold2 - "diff_threshold"
   diff_filename2 = [sprintf('%03d',i) '.jpg'];
   diff_fullname2 = fullfile('test_data2','diff_threshold4',diff_filename2);
   imwrite(result_img,diff_fullname2);
   
end


% Clear the noise in images with medium filter and recCleanNoise   

for i=1:frame_count
   
   % Read images from files
   imageIndexName = [sprintf('%03d',i) '.jpg'];
   img = double(imread(fullfile('test_data2','diff_threshold4',imageIndexName)));
   
   % Use medium filter to clean the noise
   img_mf = medfilt2(img, [3 3]);
   
   % Save processed frames to file
   diff_filename = [sprintf('%03d',i) '.jpg'];
   diff_fullname = fullfile('test_data2','diff_mf_threshold2222',diff_filename);
   imwrite(uint8(img_mf),diff_fullname);

end

%% Apply median filter in time dimension

count_3d = uint32(frame_count/15);
i = 0;
for iter=1:count_3d
    
    % Stack 15 frames for one time and apply 3D medium filter with 3 by 3
    % box
    i = i+1;
    imageIndexName1 = [sprintf('%03d',i) '.jpg'];
    img_stack = double(imread(fullfile('test_data2','diff_mf_threshold2222',imageIndexName1)));

    for iter2=2:15
        i = i+1;
        imageIndexName = [sprintf('%03d',i) '.jpg'];
        img = double(imread(fullfile('test_data2','diff_mf_threshold2222',imageIndexName)));
        img_stack = cat(3, img_stack, img);
    end
       
    % Use medium filter to clean the noise
    B = medfilt3(img_stack,[3 3 3]);  
   
    % Write image frames to file
    i = i-15;
    for iter2=1:15
        i = i+1;
        diff_filename = [sprintf('%03d',i) '.jpg'];
        diff_fullname = fullfile('test_data2','diff_mf_threshold3333',diff_filename);
        imwrite(uint8(B(:,:,iter2)),diff_fullname);
    end
    
end
%% graph the white intensity over frame
 
count = i;
S = zeros(1,count);
for i=1:count
    imageIndexName = [sprintf('%03d',i) '.jpg'];
    img_curr = double(imread(fullfile('test_data2','diff_mf_threshold333',imageIndexName)));
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

% count = 360;  % count number for diff_mf_threshold3
% count = 225;  % diff_mf_threshold33
% count = 345;    % diff_mf_threshold333
count = 315;  % diff_mf_threshold3333

% From This line to the line with equal signs for box bounding algorithm

leng = zeros(1, count);
for itera=1:count

    imageIndexName = [sprintf('%03d',itera) '.jpg'];
    img = double(imread(fullfile('test_data2','diff_mf_threshold3333',imageIndexName)));

    thresholdValue = 240;

    line([thresholdValue, thresholdValue], ylim, 'Color', 'r');
    img = imfill(img);
    
    vertical_sum = sum(img,2);
     
    % Find the start_index and end_index of horizontal_sum
    peak_threshold = 500;
    vertical_start_index = 1;
    for i=1:length(vertical_sum)-1; % Loop through vector intensityOverTime - 1 to avoid accessing past the vector
        difference=abs(vertical_sum(i+1)-vertical_sum(i)); % calculate difference between neighboring intensities        
        if difference > peak_threshold % If statement to determine start time index
            vertical_start_index=i;
            i;
            break;
        end
    end

    peak_threshold_rev = 500;
    vertical_stop_index = 1;

    for i=length(vertical_sum):-1:2; % Loop through vector intensityOverTime - 1 to avoid accessing past the vector
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

%===================================================================================================

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
