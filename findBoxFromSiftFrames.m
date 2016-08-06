function [start_x, start_y, height, width] = findBoxFromSiftFrames(frames)

    % (start_x, start_y) is the upper left corner of the box

    x = frames(1,:)
    y = frames(2,:)

    Xs = sort(x,'ascend');
    Ys = sort(y,'ascend');

    length(x);

    x_min = Xs(20);
    
    x_max = Xs(length(Xs) - 20);
    
    y_min = Ys(10);
    
    y_max = Ys(length(Ys) - 10);

    start_x = x_min;
    start_y = y_min;
   
    height = y_max - y_min;
    width = x_max - x_min;
end