%% Process all video files and save SitStand Test Event Intensty to sitStandProcessedDataMap.mat
% Note that all video names have to be the patient ID

path_videos_dir = './tempVideos'; % This is the dir contains all videos to be processed
path_save_dir = './tempProcessedFolder'; % This is the dir to save all processed data

% Create a new sitStandProcessedDataMap
% sitStandProcessedDataMap = containers.Map;

% Load the saved data first
%savedDataMap = load('sitStandProcessedDataMap.mat');

files = dir(path_videos_dir);
fileIndex = find(~[files.isdir]);

% savedDataMap('12321') = AnalyzeSitStandRGB( path_rgb_video, path_save_dir );

% Load all movies in the directory
for i = 1:length(fileIndex)
    
    videoFileName = files(fileIndex(i)).name; 
    parsed = strsplit(videoFileName, '.');
    patientID = char(parsed(1));
    
    if isempty(patientID) == false % Make srue the file is valid
        path_rgb_video = strcat(strcat(path_videos_dir, '/'), videoFileName);
        path_patient_save_dir = strcat(strcat(path_save_dir, '/'), patientID);

        disp(strcat('======Processing pratient with ID: ', patientID)); % Display info

        % Save each analyzed sitStand event intensity to the data map
    %     try
        AnalyzeBalanceRGB( path_rgb_video, path_patient_save_dir );
        % Just to be safe, save the data to file
        %save('sitStandProcessedDataMap.mat' ,'savedDataMap');
    %     catch
    %         error(strcat('Error occurred when processing: ', videoFileName));
    %     end
    
    end
end


%% Plot Sit Stand Total Time vs Ground Truth

% Each row [calculated total sitstand cycle, ground truth]
% Each column contains the person's ID
y = [15.4 15; 
     10.5667 9.16; 
     15.233 15.96; 
     11.3 10.56;
     8.6667 9.6;
     11.5 11.57;
     12.333 12.8;
     8.4333 7.54;
     10.3333 10.07;
     12.5333 12.03;
     ];
bar(y)
set(gca,'XTickLabel',{'10029', '10030', '10033', '10035', '10037', '10044', '10086', '10141', '10147', '10149'})
legend('calculated sit stand time', 'ground truth');
% xlabel('Do whatever');
ylabel('Time (second)');
title('Sit Stand Total Time');
