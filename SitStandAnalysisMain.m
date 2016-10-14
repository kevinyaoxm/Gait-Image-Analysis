
% sitStandProcessedDataMap = containers.Map;
% Load the processed data first
load 'sitStandProcessedDataMap.mat'

% sitStandProcessedDataMap('12321') = AnalyzeSitStandRGB( path_rgb_video, path_save_dir );

%
% sitStandProcessedData(1, :) = [12321, leng_smooth];
% sitStandProcessedData(2, :) = [12322, leng_smooth];

path_videos_dir = './tempVideos';
path_save_dir = './tempProcessedFolder';

files = dir(path_videos_dir);
fileIndex = find(~[files.isdir]);

% Load all movies in the directory
for i = 1:length(fileIndex)
    
    videoFileName = files(fileIndex(i)).name;
    parsed = strsplit(videoFileName, '.');
    patientID = parsed(1)
    path_rgb_video = strcat(strcat(path_videos_dir, '/'), videoFileName)
    path_patient_save_dir = strcat(strcat(path_save_dir, '/'), patientID)
    sitStandProcessedDataMap(patientID) = AnalyzeSitStandRGB( path_rgb_video, path_patient_save_dir );
    
end


save('sitStandProcessedDataMap.mat' ,'sitStandProcessedDataMap');
