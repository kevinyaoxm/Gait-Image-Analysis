%% Reading the Input RGB Video, get Y channal of yuv domain

inputRGBVideo = VideoReader('test_data2/SitStand2.mp4');

% Get the frame of RGB Video and convert each picture to YUV color space
i = 1;
while hasFrame(inputRGBVideo)
    
    % read image frame from original RGB Video
    % save image jpg file to images folder
    img = readFrame(inputRGBVideo);
   
      filename = [sprintf('%03d',i) '.jpg'];
      fullname = fullfile('test_data2','images2',filename);
      imwrite(img,fullname);
   
      % map jpg image frame from rgb to yuv color space
      yuvImg_pre = rgb2ycbcr(img);
      yuvImg = imadjust(yuvImg_pre(:,:,1));
      
      yuvImg(:, 1550:1920) = 0;
      
      yuv_filename = [sprintf('%03d',i) '.jpg'];
      yuv_fullname = fullfile('test_data2','yuv_images2',yuv_filename);
      imwrite(yuvImg,yuv_fullname);
 
   i = i+1;
end

%% Get the pixel difference images with individual and area threshold

count = i - 1;
for i=1:count
   
   % get the previous and next image | diff_images - "diff"
   imageIndexName_prev = [sprintf('%03d',i) '.jpg'];
   imageIndexName_next = [sprintf('%03d',i+1) '.jpg'];
   img_prev = double(imread(fullfile('test_data2','yuv_images2',imageIndexName_prev)));
   img_next = double(imread(fullfile('test_data2','yuv_images2',imageIndexName_next)));
   
   % Pixel difference threshold
   diff_image = abs(img_next-img_prev);
   [row, col] = size(diff_image);
   diff_index = diff_image >= 18;
   result_img = zeros(row, col);
   result_img(diff_index) = diff_image(diff_index);
  
   % write to the file | diff_threshold2 - "diff_threshold"
   diff_filename2 = [sprintf('%03d',i) '.jpg'];
   diff_fullname2 = fullfile('test_data2','diff_threshold2',diff_filename2);
   imwrite(result_img,diff_fullname2);
end


%% Clear the noise in images with medium filter and recCleanNoise   

for i=1:count
   
   % Read images from files
   imageIndexName = [sprintf('%03d',i) '.jpg'];
   img = double(imread(fullfile('test_data2','diff_threshold2',imageIndexName)));
   
   % Use medium filter to clean the noise
   img_mf = medfilt2(img, [3 3]);
   
   % Use recCleanNoise to clean the noise
   % result_img = recCleanNoise(img, 70000);
   
   diff_filename = [sprintf('%03d',i) '.jpg'];
   diff_fullname = fullfile('test_data2','diff_mf_threshold22',diff_filename);
   imwrite(uint8(img_mf),diff_fullname);
end

%% Apply median filter in time dimension

count = 1267/15;
i = 0;
for iter=1:count
    i = i+1;
    iter
    imageIndexName1 = [sprintf('%03d',i) '.jpg'];
    img_stack = double(imread(fullfile('test_data2','diff_mf_threshold22',imageIndexName1)));
        
    for iter2=2:15
        i = i+1;
        % Read images from files
        imageIndexName = [sprintf('%03d',i) '.jpg'];
        img = double(imread(fullfile('test_data2','diff_mf_threshold22',imageIndexName)));
        img_stack = cat(3, img_stack, img);
    end
       
    % Use medium filter to clean the noise
    B = medfilt3(img_stack,[3 3 3]);  
   
    i = i-15;
    for iter2=1:15
        i = i+1;
        diff_filename = [sprintf('%03d',i) '.jpg'];
        diff_fullname = fullfile('test_data2','diff_mf_threshold33',diff_filename);
        imwrite(uint8(B(:,:,iter2)),diff_fullname);
    end
end

%% graph the white intensity over frame
 
count = 270;
S = zeros(1,count);
for i=1:count
    % get the previous and next image
    imageIndexName_curr = [sprintf('%03d',i) '.jpg'];
    img_curr = double(imread(fullfile('test_data2','diff_mf_threshold33',imageIndexName_curr)));
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
title('Gait Test Event Intensty Over Time');

%% Calculate the position of the person by the original RGB video

count = 270;

for itera=1:count
    itera
    imageIndexName = [sprintf('%03d',itera) '.jpg'];
    img = double(imread(fullfile('test_data2','diff_mf_threshold33',imageIndexName)));

%     figure;
%     [pixelCount, grayLevels] = imhist(img);
%     bar(pixelCount);
%     title('Histogram of original image');
%     xlim([0 grayLevels(end)]); % Scale x axis manually.

    thresholdValue = 240;

    line([thresholdValue, thresholdValue], ylim, 'Color', 'r');
    img = imfill(img);
    binaryImage = imbinarize(img, 80);
    binaryImage = imfill(binaryImage, 'holes');
    % imshow(binaryImage, []);

    horizontal_sum_image = sum(binaryImage,1);
    % plot(horizontal_sum_image);

    %imshow(binaryImage, []);

    horizontal_sum = sum(img,1);
    vertical_sum = sum(img,2);
    % Find the start_index and end_index of horizontal_sum
    peak_threshold = 1000;
    horizontal_start_index = 1;
    for i=1:length(horizontal_sum)-1; % Loop through vector intensityOverTime - 1 to avoid accessing past the vector
        difference=abs(horizontal_sum(i+1)-horizontal_sum(i)); % calculate difference between neighboring intensities
        if difference > peak_threshold % If statement to determine start time index
            horizontal_start_index=i;
            break;
        end
    end

    peak_threshold_rev = 900;

    horizontal_stop_index = 1;
    for i=length(horizontal_sum):-1:3; % Loop through vector intensityOverTime - 1 to avoid accessing past the vector
        difference = abs(horizontal_sum(i)-horizontal_sum(i-1)); % calculate difference between neighboring intensities
        if difference > peak_threshold_rev  && (horizontal_sum(i-2) > 2000)  % If statement to determine start time index
            horizontal_stop_index=i;
            break;
        end
    end

%     subplot(1,2,1);
%     x = 1:size(horizontal_sum, 2);
%     plot (x, horizontal_sum);
%     hold on;
%     plot ([horizontal_start_index, horizontal_stop_index], [horizontal_sum(horizontal_start_index), horizontal_sum(horizontal_stop_index)],'r^');
%     axis tight;
%     ylabel('Event Intensity');
%     xlabel('Pixel Coordinate');
%     title('Distribution of event intensity - horizontal sum');
%     hold off;
%     
    % Find the start_index and end_index of horizontal_sum

    peak_threshold = 500;
    max_di = 0;
    iiii = 0;
    vertical_start_index = 1;
    for i=1:length(vertical_sum)-1; % Loop through vector intensityOverTime - 1 to avoid accessing past the vector
        difference=abs(vertical_sum(i+1)-vertical_sum(i)) % calculate difference between neighboring intensities
        if difference > max_di
            max_di = difference;
            iiii = i;
        end
        
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
    
%     subplot(1,2,2);
%     x = 1:size(vertical_sum, 1);
%     plot (x, vertical_sum);
%     hold on;
%     plot ([vertical_start_index, vertical_stop_index], [vertical_sum(vertical_start_index), vertical_sum(vertical_stop_index)],'r^');
%     axis tight;
%     ylabel('Event Intensity');
%     xlabel('Pixel Coordinate');
%     title('Distribution of event intensity - vertical sum');
%     hold off;

    % Plot the box around the person

    vertical_start_index;
    vertical_stop_index;
    horizontal_start_index;
    horizontal_stop_index;

    box_width = horizontal_stop_index - horizontal_start_index;
    box_height = vertical_stop_index - vertical_start_index;
    start_x = horizontal_start_index;
    start_y = vertical_start_index;

    %figure;
    imshow(binaryImage, []);
    hold on;
    rectangle('Position',[start_x start_y box_width box_height], 'EdgeColor','r',...
        'LineWidth',3);
    
    I = getframe(gcf);
    box_filename = [sprintf('%03d',itera) '.jpg'];
    box_fullname = fullfile('test_data2','box',box_filename);
    imwrite(I.cdata,box_fullname);
    
end


%% Calculate the position of the person by the original RGB video

count = 270;
S = zeros(1, 345);
for itera=1:count

    imageIndexName = [sprintf('%03d',itera) '.jpg'];
    img = double(imread(fullfile('test_data2','diff_mf_threshold33',imageIndexName)));

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
    
    % Plot the box around the person

    vertical_start_index;
    vertical_stop_index;

    midpoint = vertical_stop_index - vertical_start_index;
    S(itera) = midpoint;
    
end

figure;
x = 1:size(S, 2);
plot (x, S);
hold on;
plot ([1, count], [S(1), S(count)],'r^');
hold off;
axis tight;
ylabel('Midpoint');
xlabel('Time elapsed in 1 frame');
title('Gait Test Event Intensty Over Time');
%%

S_smooth = smooth(S,15);

figure;
x = 1:size(S_smooth, 1);
plot (x, S_smooth);
hold on;
plot ([1, count], [S_smooth(1), S_smooth(count)],'r^');
hold off;
axis tight;
ylabel('Midpoint');
xlabel('Time elapsed in 1 frame');
title('Gait Test Event Intensty Over Time');


%%

[Maxima,MaxIdx] = findpeaks(S_smooth, 'MinPeakDistance', 30, 'MinPeakHeight',750);
DataInv = 1.01*max(S_smooth) - S_smooth;
% bnd = 242;
% S_smooth(DataInv>bnd) = bnd;

[Minima,MinIdx] = findpeaks(DataInv, 'MinPeakDistance', 30);

figure
x = 1:size(S_smooth, 1);
plot (x, S_smooth);
hold on;
plot(MinIdx, S_smooth(MinIdx),'r^');
plot(MaxIdx, Maxima,'b^');
hold off;
axis tight;



%% Save the sequence of frames into video

inputRGBVideo = VideoReader('test_data/SitStand.mp4');

imageNames = dir(fullfile('test_data2','box','*.jpg'));
imageNames = {imageNames.name}';

outputVideo = VideoWriter(fullfile('test_data2/output','box.avi'));
outputVideo.FrameRate = inputRGBVideo.FrameRate;
open(outputVideo)

%for i = 1:length(imageNames)
for i = 1:1088

   imageIndexName = [sprintf('%03d',i) '.jpg'];
   %img = imread(fullfile('test_data','yuv_images',imageNames{i}));
   img = imread(fullfile('test_data2','box',imageIndexName));
   writeVideo(outputVideo,img);
end

close(outputVideo);