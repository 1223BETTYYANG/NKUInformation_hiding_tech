function main()
    % 读取图像并转换为二值图像
    originalImage = im2bw(imread("原图.png"));

    % 将图像分割为两部分
    [part1, part2] = divide(originalImage);

    % 显示原始二值图像
    figure;
    imshow(originalImage);
    title('原始二值图像');

    % 显示第一部分伪装图像
    figure;
    imshow(part1);
    title('第一部分伪装图像');

    % 显示第二部分伪装图像
    figure;
    imshow(part2);
    title('第二部分伪装图像');

    % 合并两部分图像并显示恢复后的图像
    recoveredImage = merge(part1, part2);
    figure;
    imshow(recoveredImage);
    title('恢复后的图像');

    % 指定保存图像的文件夹路径
    outputFolder = 'D:\61homework\信息隐藏技术\lab1'; % 修改为你的目标文件夹路径
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder); % 如果文件夹不存在，则创建
    end

    % 保存伪装图像和恢复后的图像
    imwrite(part1, fullfile(outputFolder, '伪装图像1.png'));
    imwrite(part2, fullfile(outputFolder, '伪装图像2.png'));
    imwrite(recoveredImage, fullfile(outputFolder, '恢复后的图像.png'));

    disp('图像已保存到指定文件夹。');
end

function [image1, image2] = divide(image)
    % 获取原始图像的尺寸
    [rows, cols] = size(image);
    new_rows = 2 * rows;
    new_cols = 2 * cols;
    
    % 初始化两个新图像，填充为255（白色）
    image1 = 255 * ones(new_rows, new_cols);
    image2 = 255 * ones(new_rows, new_cols);

    % 遍历原始图像的每个像素
    for row = 1:rows
        for col = 1:cols
            % 生成一个1到3之间的随机数
            key = randi(3);
            
            % 计算新图像中的位置
            new_row = 1 + 2 * (row - 1);
            new_col = 1 + 2 * (col - 1);
            
            % 根据随机数 key 和原始图像的像素值来决定像素的分布
            if key == 1
                % 在 image1 中填充两个黑色像素
                image1(new_row, new_col:new_col+1) = 0;
                if image(row, col) == 0  % 如果原始像素是黑色
                    image2(new_row+1, new_col:new_col+1) = 0;
                else  % 如果原始像素是白色
                    image2(new_row:new_row+1, new_col+1) = 0;
                end
            elseif key == 2
                % 在 image1 中填充两个黑色像素
                image1(new_row, new_col) = 0;
                image1(new_row+1, new_col+1) = 0;
                if image(row, col) == 0  % 如果原始像素是黑色
                    image2(new_row, new_col+1) = 0;
                    image2(new_row+1, new_col) = 0;
                else  % 如果原始像素是白色
                    image2(new_row:new_row+1, new_col) = 0;
                end
            else  % key == 3
                % 在 image1 中填充两个黑色像素
                image1(new_row:new_row+1, new_col) = 0;
                if image(row, col) == 0  % 如果原始像素是黑色
                    image2(new_row, new_col+1) = 0;
                    image2(new_row+1, new_col+1) = 0;
                else  % 如果原始像素是白色
                    image2(new_row, new_col:new_col+1) = 0;
                end
            end
        end
    end
end



function outputImage = merge(inputImage1, inputImage2)
    % 获取输入图像的尺寸
    [rows, cols] = size(inputImage1);

    % 初始化输出图像为全白（255）
    outputImage = 255 * ones(rows, cols);

    % 遍历每个像素
    for row = 1:rows
        for col = 1:cols
            % 如果两个输入图像在当前位置的像素值均为非零，则输出图像对应像素值设为非零（255）
            if inputImage1(row, col) && inputImage2(row, col)
                outputImage(row, col) = 255;
            else
                outputImage(row, col) = 0;
            end
        end
    end
end
