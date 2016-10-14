
% sitStandProcessedDataMap = containers.Map;
% Load the processed data first
load 'sitStandProcessedDataMap.mat'

% sitStandProcessedDataMap('12321') = AnalyzeSitStandRGB( path_rgb_video, path_save_dir );

%
% sitStandProcessedData(1, :) = [12321, leng_smooth];
% sitStandProcessedData(2, :) = [12322, leng_smooth];

path_videos_dir = './';
path_save_dir = '';

files = dir(path_videos_dir);
fileIndex = find(~[files.isdir]);

% Load all movies in the directory
for i = 1:length(fileIndex)
    
    videoFileName = files(fileIndex(i)).name;
    path_rgb_video = path_videos_dir + '/' + videoFileName
    sitStandProcessedDataMap(fileName) = AnalyzeSitStandRGB( path_rgb_video, path_save_dir );
    
end


save('sitStandProcessedDataMap.mat' ,'sitStandProcessedDataMap');
