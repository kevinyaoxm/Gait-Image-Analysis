function [ gapIndex ] = findGap( horizontal_sum_image )
%FINDGAP Summary of this function goes here
%   Detailed explanation goes here

counter = 0;

for index = 1920:1
    if( horizontal_sum_image(index) ~= 0 )
        counter = 1;
    end
    
    if( counter == 1 && horizontal_sum_image(index) == 0 )
        gapIndex = index;
        break
    end
end

end

