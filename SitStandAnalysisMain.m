
%% Process all video files and save SitStand Test Event Intensty to sitStandProcessedDataMap.mat
% Note that all video names have to be the patient ID

path_videos_dir = './tempVideos'; % This is the dir contains all videos to be processed
path_save_dir = './tempProcessedFolder'; % This is the dir to save all processed data

% Create a new sitStandProcessedDataMap
% sitStandProcessedDataMap = containers.Map;

% Load the saved data first
savedDataMap = load('sitStandProcessedDataMap.mat');

files = dir(path_videos_dir);
fileIndex = find(~[files.isdir]);

% savedDataMap('12321') = AnalyzeSitStandRGB( path_rgb_video, path_save_dir );

% Load all movies in the directory
for i = 1:length(fileIndex)
    
    videoFileName = files(fileIndex(i)).name; 
    parsed = strsplit(videoFileName, '.');
    patientID = char(parsed(1));
    path_rgb_video = strcat(strcat(path_videos_dir, '/'), videoFileName);
    path_patient_save_dir = strcat(strcat(path_save_dir, '/'), patientID);
    
    disp(strcat('======Processing pratient with ID: ', patientID)); % Display info
    
    % Save each analyzed sitStand event intensity to the data map
    try
        savedDataMap(patientID) = AnalyzeSitStandRGB( path_rgb_video, path_patient_save_dir );
        % Just to be safe, save the data to file
        save('sitStandProcessedDataMap.mat' ,'savedDataMap');
    catch
        error(strcat('Error occurred when processing: ', videoFileName));
    end
end


%% Load processed data above and graph them



