 

%% graph the white intensity over frame
    
    path_save_dir = './tempProcessedFolder'; % This is the dir to save all processed data
    path_pixel_difference = 'diff_mf_threshold3';
    
    files = dir(path_save_dir);
    fileIndex = find([files.isdir]);
    
    for i = 3:length(fileIndex)
        
        folderName = files(fileIndex(i)).name;
        imageDir = dir(strcat(strcat(path_save_dir, '/'),(strcat(strcat(folderName, '/'), path_pixel_difference))));
        
        count = length(find(~[imageDir.isdir]));

            leng = zeros(1, count);
        for itera=1:count
            try
                imageIndexName = [sprintf('%03d',itera) '.jpg'];
                img = double(imread(fullfile(path_save_dir, folderName, path_pixel_difference, imageIndexName)));

                thresholdValue = 240;

                line([thresholdValue, thresholdValue], ylim, 'Color', 'r');
                img = imfill(img);

                vertical_sum = sum(img,2);

                % Find the start_index and end_index of horizontal_sum
                peak_threshold = 400;
                vertical_start_index = 1;
                for i=1:length(vertical_sum)-1 % Loop through vector vertical_sum - 1 to avoid accessing past the vector
                    difference=abs(vertical_sum(i+1)-vertical_sum(i)); % calculate difference between neighboring intensities
                    if difference > peak_threshold % If statement to determine start time index
                        vertical_start_index=i;
                        break;
                    end
                end
                
                midpoint = vertical_start_index;
                leng(itera) = midpoint;
            catch
            end
        end
        %~%~%~%~%~%~%~%~%~%~%~%~%~%~% Box bounding algorithm ends %~%~%~%~%~%~%~%~%~%~%~%%~%~%~%~~

        leng_smooth = smooth(leng,15);

%     %     figure;
%             x = 1:size(leng_smooth, 1);
%             plot (x, leng_smooth);
%             hold on;
%             plot ([1, count], [leng_smooth(1), leng_smooth(count)],'r^');
%             hold off;
%             axis tight;
%             ylabel('Y-coordinate of midpoint');
%             xlabel('Time elapsed in 1 frame');
%             title('SitStand Test Event Intensty Over Time');

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
            
            totalCycleTime = MaxIdx(length(MaxIdx)) - MaxIdx(1);

            figure;
            x = 1:size(leng_smooth, 1);
            plot (x, leng_smooth);
            hold on;
            plot(MinIdx, leng_smooth(MinIdx),'r^');
            plot(MaxIdx, leng_smooth(MaxIdx),'b^');
            hold off;
            axis tight;
            str = strcat('total cycle time: ', num2str(totalCycleTime/30));
            dim = [.2 .5 .3 .3];
            annotation('textbox',dim,'String',str,'FitBoxToText','on');

            savefig(strcat(strcat(strcat(strcat(path_save_dir, '/'), folderName), '/'), 'plot_With_Total_Cycle_Time'))
    end