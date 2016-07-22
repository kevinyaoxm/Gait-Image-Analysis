function [ gapIndex ] = findGap( horizontal_sum_image )
%FINDGAP Summary of this function goes here
%   Detailed explanation goes here

counter = 0;
zeroCounter = 0;
gapIndex = 1920;

for index = 1920:-1:1
    if( horizontal_sum_image(index) > 250 )
        counter = 1;
    end
    
    if( counter == 1 && horizontal_sum_image(index) == 0 )
        zeroCounter = zeroCounter + 1;
    end
    
    if( zeroCounter == 10 )
        gapIndex = index;
        break
    end
end

gapIndex

end

