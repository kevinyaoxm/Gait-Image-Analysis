%% Reading the Input RGB Video

inputRGBVideo = VideoReader('test_data2/SitStand3.mp4');

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
    % get Y channal of yuv domain
    yuvImg_pre = rgb2ycbcr(img);
    yuvImg = imadjust(yuvImg_pre(:,:,1));

    % Hardcoding research assistant away
    yuvImg(:, 1550:1920) = 0;
    yuvImg(:, 1:830) = 0;

    yuv_filename = [sprintf('%03d',i) '.jpg'];
    yuv_fullname = fullfile('test_data2','yuv_images2',yuv_filename);
    imwrite(yuvImg,yuv_fullname);
    i = i+1;
end

%% Get the pixel difference images with individual and area threshold

frame_count = i - 1;
for i=1:frame_count-1
   
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


% Clear the noise in images with medium filter and recCleanNoise   

for i=1:frame_count
   
   % Read images from files
   imageIndexName = [sprintf('%03d',i) '.jpg'];
   img = double(imread(fullfile('test_data2','diff_threshold2',imageIndexName)));
   
   % Use medium filter to clean the noise
   img_mf = medfilt2(img, [3 3]);
   
   % Save processed frames to file
   diff_filename = [sprintf('%03d',i) '.jpg'];
   diff_fullname = fullfile('test_data2','diff_mf_threshold22',diff_filename);
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
    img_stack = double(imread(fullfile('test_data2','diff_mf_threshold22',imageIndexName1)));

    for iter2=2:15
        i = i+1;
        imageIndexName = [sprintf('%03d',i) '.jpg'];
        img = double(imread(fullfile('test_data2','diff_mf_threshold22',imageIndexName)));
        img_stack = cat(3, img_stack, img);
    end
       
    % Use medium filter to clean the noise
    B = medfilt3(img_stack,[3 3 3]);  
   
    % Write image frames to file
    i = i-15;
    for iter2=1:15
        i = i+1;
        diff_filename = [sprintf('%03d',i) '.jpg'];
        diff_fullname = fullfile('test_data2','diff_mf_threshold33',diff_filename);
        imwrite(uint8(B(:,:,iter2)),diff_fullname);
    end
    
end
%% graph the white intensity over frame
 
count = i;
S = zeros(1,count);
for i=1:count
    imageIndexName = [sprintf('%03d',i) '.jpg'];
    img_curr = double(imread(fullfile('test_data2','diff_mf_threshold33',imageIndexName)));
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

leng = zeros(1, count);
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
    
    midpoint = vertical_stop_index - vertical_start_index;
    leng(itera) = midpoint;
    
end

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

% Find the maxima and minima point
[Maxima,MaxIdx] = findpeaks(leng_smooth, 'MinPeakDistance', 30, 'MinPeakHeight',750);
DataInv = 1.01*max(leng_smooth) - leng_smooth;
[Minima,MinIdx] = findpeaks(DataInv);

% Find the time stamp for each sit and stand cycle
Stand_Time = Maxima;  % The time stamp when the person stand
Stop_Time = []; % The time stamp when the person sit down
Start_Time = []; % The time stamp when the person stand up for the next cycle

length(Stand_Time); % should be 5
Stand_Time = Stand_Time(1:5);


for i = 2:length(MaxIdx)
    Sitdown_TimeIdx = MinIdx(MinIdx < MaxIdx(i) & (MinIdx > MaxIdx(i-1)));
    Stop_Time = [Stop_Time Sitdown_TimeIdx(1)];
    Start_Time = [Start_Time Sitdown_TimeIdx(length(Sitdown_TimeIdx))];
end

Sitdown_TimeIdx = MinIdx(MinIdx > MaxIdx(length(MaxIdx)))
Stop_Time = [Stop_Time Sitdown_TimeIdx(1)];

timeStamp = [];

for i=1:4
    med = mean([Start_Time(i), Stop_Time(i)]);
    timeStamp = [timeStamp med]
end

% Find the beginning time stamp of the sit and stand test
StandingIntensity = S_smooth(MaxIdx);
StandingIntensity_Avg = mean(StandingIntensity);
[~, fir] = min(S_smooth-StandingIntensity_Avg);
timeStamp = [fir timeStamp Stop_Time(end)]

% figure for displaying two time stamps
figure;
x = 1:length(leng_smooth);
plot (x, leng_smooth);
hold on;
plot(MaxIdx, leng_smooth(MaxIdx),'r^');
plot(timeStamp, leng_smooth(uint64(timeStamp)),'b^');
hold off;
axis tight;

% Print out the time stamp table for SitStand Test 
SitStandCount = {'1','2','3','4','5'};
T = table;
T.SitStandCount = SitStandCount';
T.StartTimeStamp = timeStamp(1:5)';
T.StopTimeStamp = timeStamp(2:6)';
