function [ pixel_diff_video ] = RGB2Pix_diff( path_rgb_video, path_save_dir )
%	Function for converting RGB videos to Pixel Difference videos
%   INPUT path_rgb_video: full path of the video to be analyzed
%         path_save_dir: full path of the directory name used to save
%         analyzed data
%   
%   OUTPUT pixel_diff_video: pixel difference video, noise is median
%   filtered


    %% Reading the Input RGB Video
    
    
    inputRGBVideo = VideoReader(path_rgb_video);
    
    % Create folders to hold the processed files
    path_diff_mf_threshold1 = 'diff_mf_threshold1';
    path_diff_mf_threshold2 = 'diff_mf_threshold2';
    path_diff_mf_threshold3 = 'diff_mf_threshold3';
    path_pixel_diff_vid = 'path_pixel_diff_vid';
    path_yuv_images = 'yuv_images';
    path_images_dir = 'images';
    
    mkdir(path_save_dir); % This is the parent directory that contains all processed data of a patient
    mkdir(strcat(strcat(path_save_dir, '/'), path_diff_mf_threshold1));
    mkdir(strcat(strcat(path_save_dir, '/'), path_diff_mf_threshold2));
    mkdir(strcat(strcat(path_save_dir, '/'), path_diff_mf_threshold3));
    mkdir(strcat(strcat(path_save_dir, '/'), path_pixel_diff_vid));
    mkdir(strcat(strcat(path_save_dir, '/'), path_yuv_images));
    mkdir(strcat(strcat(path_save_dir, '/'), path_images_dir));
    
    fprintf('Reading Input Video and Computing frames in yuv Y-channel.\n') ;
    
    % Get the frame of RGB Video and convert each picture to YUV color space
    
    %%%%%%%%%%%%%%%%%%%%% Get Y channel of YUV image frames starts %%%%%%%%%%%%%%%%%%%
    i = 1;
    while hasFrame(inputRGBVideo)
        
        % read image frame from original RGB Video
        % save image jpg file to images folder
        img = readFrame(inputRGBVideo);
        
        % filename = [sprintf('%03d',i) '.jpg'];
        % fullname = fullfile(path_save_dir,path_images_dir,filename);
        % imwrite(img,fullname);
        
        % map jpg image frame from rgb to yuv color space
        % get Y channal of yuv domain
        yuvImg_pre = rgb2ycbcr(img);
        yuvImg = imadjust(yuvImg_pre(:,:,1));
        
        % Hardcoding research assistant away
        yuvImg(:, 1400:1920) = 0;
        yuvImg(:, 1:830) = 0;
        
        yuv_filename = [sprintf('%03d',i) '.jpg'];
        yuv_fullname = fullfile(path_save_dir, path_yuv_images,yuv_filename);
        try
            imwrite(yuvImg,yuv_fullname);
        catch
        end
        i = i+1;
    end
    %%%%%%%%%%%%%%%%%%% Get Y channel of YUV image frames ends %%%%%%%%%%%%%%%%%%%
    
    %% Get the pixel difference images with individual and area threshold
    
    fprintf('Computing Pixel Difference Image.\n') ;
    
    %==================== Compute Pixel Difference Image starts ===================
    frame_count = i - 2;
%     numberOfTruePixels = 0;
    total_variation = 0;
    for i=1:frame_count
        
        % get the previous and next image | diff_images - "diff"
        imageIndexName_prev = [sprintf('%03d',i) '.jpg'];
        imageIndexName_next = [sprintf('%03d',i+1) '.jpg'];
        try
            img_prev = double(imread(fullfile(path_save_dir,path_yuv_images,imageIndexName_prev)));
            img_next = double(imread(fullfile(path_save_dir,path_yuv_images,imageIndexName_next)));
            
            % Pixel difference threshold
            diff_image = abs(img_next-img_prev);
            [row, col] = size(diff_image);
            diff_index = diff_image >= 18;
            result_img = zeros(row, col);
            result_img(diff_index) = diff_image(diff_index);
%             nWhite = size(find(result_img) == 255);
%             numberOfTruePixels = numberOfTruePixels + nWhite;
            
%             %%%
%             diff_image = imabsdiff(img_next,img_prev);
%             total_variation = total_variation + sum(sum(diff_image))/(size(diff_image,1)*size(diff_image,2));
            % write to the file | diff_threshold2 - "diff_threshold"
            diff_filename2 = [sprintf('%03d',i) '.jpg'];
            diff_fullname2 = fullfile(path_save_dir,path_diff_mf_threshold1,diff_filename2);
            imwrite(result_img,diff_fullname2);
        catch
        end
    end
    
    
    %==================== Compute Pixel Difference Image ends ====================
    
    
    % Clear the noise in images with medium filter
    
    %~~~~~~~~~~~~~~~ Apply medium filter on spacital domain starts ~~~~~~~~~~~~~~~~~
    fprintf('Apply median filter on spatial domain.\n') ;
    for i=1:frame_count
        
        % Read images from files
        imageIndexName = [sprintf('%03d',i) '.jpg'];
        try
            img = double(imread(fullfile(path_save_dir,path_diff_mf_threshold1,imageIndexName)));
            
            % Use medium filter to clean the noise
            img_mf = medfilt2(img, [3 3]);
            
            % Save processed frames to file
            diff_filename = [sprintf('%03d',i) '.jpg'];
            diff_fullname = fullfile(path_save_dir,path_diff_mf_threshold2,diff_filename);
            imwrite(uint8(img_mf),diff_fullname);
        catch
        end
    end
    %~~~~~~~~~~~~~~~ Apply medium filter on spacital domain ends ~~~~~~~~~~~~~~~~~
    
    %% Apply median filter in time dimension
    
    %=%=%=%=%=%=%=%= Apply medium filter on time domain starts %=%=%=%=%=%=%=%=%=%=
    fprintf('Apply median filter in time domain.\n') ;
    count_3d = uint32(frame_count/15);
    i = 0;
    for iter=1:count_3d
        
        % Stack 15 frames for one time and apply 3D medium filter with 3 by 3
        % box
        while( i < frame_count - 1 )
            i = i+1;
            imageIndexName1 = [sprintf('%03d',i) '.jpg'];
            img_stack = double(imread(fullfile(path_save_dir,path_diff_mf_threshold2,imageIndexName1)));
            
            for iter2=2:15
                i = i+1;
                imageIndexName = [sprintf('%03d',i) '.jpg'];
                try
                    img = double(imread(fullfile(path_save_dir,path_diff_mf_threshold2,imageIndexName)));
                    img_stack = cat(3, img_stack, img);
                catch
                end
            end
            % Use medium filter to clean the noise
            B = medfilt3(img_stack,[3 3 3]);
            
            % Write image frames to file
            i = i-15;
            for iter2=1:15
                i = i+1;
                diff_filename = [sprintf('%03d',i) '.jpg'];
                diff_fullname = fullfile(path_save_dir,path_diff_mf_threshold3,diff_filename);
                try
                    imwrite(uint8(B(:,:,iter2)),diff_fullname);
                catch
                end
            end
        end
    end
    %=%=%=%=%=%=%=%= Apply medium filter on time domain ends %=%=%=%=%=%=%=%=%=%=


    %% Convert Pixel Difference Images into one video
    fprintf('Converting pixel difference images to video.\n') ;
    workingDir = path_diff_mf_threshold3;
    
    imageNames = dir(fullfile(workingDir,'images','*.jpg'));
    imageNames = {imageNames.name}';
    
    shuttleVideo=VideoReader('path_rgb_video');
    
    outputVideo = VideoWriter(fullfile(path_save_dir,path_pixel_diff_vid,'Pixel_Diff_Video.avi'));
    outputVideo.FrameRate = shuttleVideo.FrameRate;
    open(pixel_diff_video)
    
    for ii = 1:length(imageNames)
        img = imread(fullfile(workingDir,'images',imageNames{ii}));
        writeVideo(pixel_diff_video,img)
    end
    
    close(pixel_diff_video)
    
end

