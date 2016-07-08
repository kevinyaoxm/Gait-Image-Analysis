function reg_img = clear_noise(img)

    rec1 = img(1:540,1:320);
    rec2 = img(1:540,321:640);
    rec3 = img(1:540,641:960);
    rec4 = img(1:540,961:1280);
    rec5 = img(1:540,1281:1600);
    rec6 = img(1:540,1601:1920);


    rec7 = img(541:1080,1:320);
    rec8 = img(541:1080,321:640);
    rec9 = img(541:1080,641:960);
    rec10 = img(541:1080,961:1280);
    rec11 = img(541:1080,1281:1600);
    rec12 = img(541:1080,1601:1920);

    rec_arr = [rec1 rec2 rec3 rec4 rec5 rec6 rec7 rec8 rec9 rec10 rec11 rec12];
    col1 = [1, 321, 641, 961, 1281, 1601, 1921, 2241, 2561, 2881, 3201, 3521];
    col2 = [320,640,960, 1280,1600, 1920, 2240, 2560, 2880, 3200, 3520, 3840];
    row1 = [1, 541];
    row2 = [540,1080];
    re_img = zeros(540, 3840);

    for i=1:12
        col_ind_start = col1(i);
        col_ind_end = col2(i);

        sectioned_img = rec_arr(:,col_ind_start:col_ind_end);
        summ = sum(sum(sectioned_img))

        if summ > 100000
            re_img(:,col_ind_start:col_ind_end) = rec_arr(:,col_ind_start:col_ind_end);
        end
    end

    reg_img = [re_img(:,1:1920); re_img(:,1921:3840)];

end