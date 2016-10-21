
%	Function for converting RGB videos to Pixel Difference videos
%   INPUT path_rgb_video: full path of the video to be analyzed
%         path_save_dir: full path of the directory name used to save
%         analyzed data
%   
%   OUTPUT pixel_diff_video: pixel difference video, noise is median
%   filtered

  
    % Create folders to hold the processed files
    path_pixel_difference = 'diff_mf_threshold3';
    path_save_dir = './tempProcessedFolder';
    
    files = dir(path_save_dir);
    fileIndex = find([files.isdir]);
    %% Convert Pixel Difference Images into one video
    
    for i = 3:length(fileIndex)
        videoFileName = files(fileIndex(i)).name; 
        parsed = strsplit(videoFileName, '.');
        patientID = char(parsed(1));
        
        pix_diff_video_filename = strcat(patientID, '_pixel_diff_video.avi');
        
        fprintf('Computing video number %d.\n', i-2) ;
        folderName = files(fileIndex(i)).name;
        imageDir = dir(strcat(strcat(path_save_dir, '/'),(strcat(strcat(folderName, '/'), path_pixel_difference))));        
        count = length(find(~[imageDir.isdir]));        
        pixel_diff_video = VideoWriter(fullfile(path_save_dir,folderName, pix_diff_video_filename));
        
        
        for itera=1:count
            imageIndexName = [sprintf('%03d',itera) '.jpg'];
            img = imread(fullfile(path_save_dir, folderName, path_pixel_difference, imageIndexName));
            open(pixel_diff_video);
            writeVideo(pixel_diff_video,img);           
        end
        close(pixel_diff_video)
    end

    
    

