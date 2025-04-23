% main() 是灰度图像叠加程序的主函数
function main()
    clc;          % 清空命令窗口
    clear all;    % 清除所有变量
    close all;    % 关闭所有图形窗口
 
    % 读取加密图像
    enc_img_path = "./图片/灰度叠加/woman.jpeg";
    enc_img = imread(enc_img_path);
    disp("加密图像的尺寸为:  ");
    disp(size(enc_img));
    figure;
    imshow(enc_img);
    title("加密图像");
    imwrite(enc_img, './图片/灰度叠加/加密图像.jpeg');% 保存加密图像副本

    % 将加密图像转换为灰度图
    gray_enc_img = rgb2gray(enc_img);
    disp("灰度加密图像的尺寸为:");
    disp(size(gray_enc_img));
    figure;
    imshow(gray_enc_img);
    title("灰度加密图像");
    imwrite(gray_enc_img, './图片/灰度叠加/灰度加密图像.bmp');% 保存灰度加密图像

    % 读取原始图像1（表情符号）
    original_img1_path = "./图片/灰度叠加/emoji.jpeg";
    original_img1 = imread(original_img1_path);
    disp("原始图像1的尺寸为: ");
    disp(size(original_img1));
    figure;
    imshow(original_img1);
    title("原始图像1");
    imwrite(original_img1, './图片/灰度叠加/原始图像1.jpeg');  % 保存原始图像1副本

    % 将原始图像1转换为灰度图
    gray_original_img1 = rgb2gray(original_img1);
    disp("灰度原始图像1的尺寸为: ");
    disp(size(gray_original_img1));
    figure;
    imshow(gray_original_img1);
    title("灰度原始图像1");
    imwrite(gray_original_img1, './图片/灰度叠加/灰度原始图像1.bmp');  % 保存灰度原始图像1

    % 读取原始图像2（鸟类）
    original_img2_path = "./图片/灰度叠加/bird.jpeg";
    original_img2 = imread(original_img2_path);
    disp("原始图像2的尺寸为: ");
    disp(size(original_img2));
    figure;
    imshow(original_img2);
    title("原始图像2");
    imwrite(original_img2, './图片/灰度叠加/原始图像2.jpeg');  % 保存原始图像2副本

    % 将原始图像2转换为灰度图
    gray_original_img2 = rgb2gray(original_img2);
    disp("灰度原始图像2的尺寸为: ");
    disp(size(gray_original_img2));
    figure;
    imshow(gray_original_img2);
    title("灰度原始图像2");
    imwrite(gray_original_img2, './图片/灰度叠加/灰度原始图像2.bmp');  % 保存灰度原始图像2

    % 对灰度加密图像进行半色调处理
    halftone_gray_enc_img = img_halftone(gray_enc_img);
    disp("半色调加密图像的尺寸为:");
    disp(size(halftone_gray_enc_img));
    figure;
    imshow(halftone_gray_enc_img);
    title("半色调加密图像");
    imwrite(halftone_gray_enc_img, './图片/灰度叠加/半色调加密图像.bmp');

    % 对灰度原始图像1进行半色调处理
    halftone_gray_original_img1 = img_halftone(gray_original_img1);
    disp("半色调原始图像1的尺寸为: ");
    disp(size(halftone_gray_original_img1));
    figure;
    imshow(halftone_gray_original_img1);
    title("半色调原始图像1");
    imwrite(halftone_gray_original_img1, './图片/灰度叠加/半色调原始图像1.bmp');

    % 对灰度原始图像2进行半色调处理
    halftone_gray_original_img2 = img_halftone(gray_original_img2);
    disp("半色调原始图像1的尺寸为: ");
    disp(size(halftone_gray_original_img2));
    figure;
    imshow(halftone_gray_original_img2);
    title("半色调原始图像2");
    imwrite(halftone_gray_original_img2, './图片/灰度叠加/半色调原始图像2.bmp');

    % 将半色调加密图像与两个半色调原始图像进行分割
    [img1, img2] = img_divide(halftone_gray_enc_img, halftone_gray_original_img1, halftone_gray_original_img2);
    disp("分割图像1的尺寸为: ");
    disp(size(img1));
    figure;
    imshow(img1);
    title("分割图像1");
    imwrite(img1, './图片/灰度叠加/分割图像1.bmp');
    disp("分割图像2的尺寸为: ");
    disp(size(img2));
    figure;
    imshow(img2);
    title("分割图像2");
    imwrite(img2, './图片/灰度叠加/分割图像2.bmp');

    % 合并分割后的图像
    merged_img = img_merge(img1,img2);
    disp("合并图像的尺寸为: ");
    disp(size(merged_img));
    figure;
    imshow(merged_img);
    title("合并图像");
    imwrite(merged_img, './图片/灰度叠加/合并图像.bmp');
end


% img_halftone(gray_img): 使用误差扩散算法对灰度图像进行半色调处理
% 输入参数:
% - gray_img: 输入的灰度图像
% 输出参数:
% - img: 处理后的半色调图像
function img = img_halftone(gray_img)
    img_size = size(gray_img);
    disp("灰度图像的尺寸是：");
    disp(img_size);
    
    x = img_size(1); % 获取图像高度（行数）
    y = img_size(2); % 获取图像宽度（列数）
    disp("图像第一维度尺寸（高度）：");
    disp(x);
    disp("图像第二维度尺寸（宽度）：");
    disp(y);
 
    for m = 1 : x
        for n = 1 : y
            if gray_img(m, n) > 127
                out = 255;  % 设置二值化阈值
            else
                out = 0;
            end
 
            error = gray_img(m, n) - out;  % 计算量化误差
 
            % 误差扩散处理（Floyd-Steinberg算法）
            if n > 1 && n < 255 && m < 255
                gray_img(m, n + 1) = gray_img(m, n + 1) + error * 7 / 16.0;  % 向右扩散
                gray_img(m + 1, n) = gray_img(m + 1, n) + error * 5 / 16.0;   % 向下扩散
                gray_img(m + 1, n - 1) = gray_img(m + 1, n - 1) + error * 3 / 16.0;  % 向左下扩散
                gray_img(m + 1, n + 1) = gray_img(m + 1, n + 1) + error * 1 / 16.0;  % 向右下扩散
                gray_img(m, n) = out;  % 更新当前像素值
            else
                gray_img(m, n) = out;  % 边界像素直接赋值
            end
        end
    end
 
    img = gray_img;  % 返回处理后的图像
end



% img_divide: 将三个输入图像按特定模式分割为两个图像
% 输入参数:
%   enc_img   - 待分割的加密图像
%   original_img1 - 第一个原始分区图像
%   original_img2 - 第二个原始分区图像
% 输出参数:
%   img1 - 分割后的第一个图像
%   img2 - 分割后的第二个图像
function [img1, img2] = img_divide(enc_img, original_img1, original_img2)
    img_size = size(enc_img);
    disp("加密图像的尺寸是：");
    disp(img_size);
 
    x = img_size(1);  % 获取图像高度
    y = img_size(2);  % 获取图像宽度
    disp("加密图像第一维度尺寸：");
    disp(x);
    disp("加密图像第二维度尺寸：");
    disp(y);
 
    % 初始化输出图像（双倍尺寸，全白背景）
    img1 = 255 * ones(2 * x, 2 * y);
    img2 = 255 * ones(2 * x, 2 * y);
    disp("分割后图像img1的尺寸：");
    disp(size(img1));
    disp("分割后图像img2的尺寸：");
    disp(size(img2));
 
    for i = 1 : x
        for j = 1 : y
            new_img_row = 2 * (i - 1) + 1;  % 计算新图像的行索引
            new_img_col = 2 * (j - 1) + 1;  % 计算新图像的列索引
            key = randi(4);  % 随机选择分割模式（1-4）
            
            switch key
                % 所有case分支均基于全白初始化，只需将对应位置设为0（黑色）
                case 1  % 模式1：对角线分割
                    if enc_img(i, j) == 0 && original_img1(i, j) == 0 && original_img2(i, j) == 0  % 黑  黑  黑
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) == 0 && original_img1(i, j) == 0 && original_img2(i, j) ~= 0  % 黑 黑 白
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) == 0 && original_img1(i, j) ~= 0 && original_img2(i, j) == 0  % 黑 白 黑
                        img1(new_img_row + 1, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col) = 0;
                        
                    elseif enc_img(i, j) == 0 && original_img1(i, j) ~= 0 && original_img2(i, j) ~= 0  % 黑 白 白
                        img1(new_img_row + 1, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) == 0 && original_img2(i, j) == 0  % 白 黑 黑
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) == 0 && original_img2(i, j) ~= 0  % 白 黑 白
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) ~= 0 && original_img2(i, j) ~= 0  % 白 白 白
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) ~= 0 && original_img2(i, j) == 0  % 白 白 黑
                        img1(new_img_row + 1, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    end
                    
                case 2 % 模式2：垂直分割
                    if enc_img(i, j) == 0 && original_img1(i, j) == 0 && original_img2(i, j) == 0  % 黑 黑 黑
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) == 0 && original_img1(i, j) == 0 && original_img2(i, j) ~= 0  % 黑 黑 白
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) == 0 && original_img1(i, j) ~= 0 && original_img2(i, j) == 0  % 黑 白 黑
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) == 0 && original_img1(i, j) ~= 0 && original_img2(i, j) ~= 0  % 黑 白 白
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) == 0 && original_img2(i, j) == 0  % 白 黑 黑
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) == 0 && original_img2(i, j) ~= 0  % 白 黑 白
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) ~= 0 && original_img2(i, j) ~= 0  % 白 白 白
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) ~= 0 && original_img2(i, j) == 0  % 白 白 黑
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    end
                    
                case 3 % 模式3：水平分割
                    if enc_img(i, j) == 0 && original_img1(i, j) == 0 && original_img2(i, j) == 0  % 黑 黑 黑
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) == 0 && original_img1(i, j) == 0 && original_img2(i, j) ~= 0  % 黑 黑 白
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row + 1, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) == 0 && original_img1(i, j) ~= 0 && original_img2(i, j) == 0  % 黑 白 黑
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) == 0 && original_img1(i, j) ~= 0 && original_img2(i, j) ~= 0  % 黑 白 白
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row, new_img_col + 1) = 0;
                        
                        img2(new_img_row + 1, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) == 0 && original_img2(i, j) == 0  % 白 黑 黑
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) == 0 && original_img2(i, j) ~= 0  % 白 黑 白
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row + 1, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) ~= 0 && original_img2(i, j) ~= 0  % 白 白 白
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        
                        img2(new_img_row + 1, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) ~= 0 && original_img2(i, j) == 0  % 白 白 黑
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col) = 0;
                        
                    end
                    
                case 4 % 模式4：棋盘格分割
                    if enc_img(i, j) == 0 && original_img1(i, j) == 0 && original_img2(i, j) == 0  % 黑 黑 黑
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col) = 0;
                        
                    elseif enc_img(i, j) == 0 && original_img1(i, j) == 0 && original_img2(i, j) ~= 0  % 黑 黑 白
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) == 0 && original_img1(i, j) ~= 0 && original_img2(i, j) == 0  % 黑 白 黑
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) == 0 && original_img1(i, j) ~= 0 && original_img2(i, j) ~= 0  % 黑 白 白
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) == 0 && original_img2(i, j) == 0  % 白 黑 黑
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) == 0 && original_img2(i, j) ~= 0  % 白 黑 白
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) ~= 0 && original_img2(i, j) ~= 0  % 白 白 白
                        img1(new_img_row + 1, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) ~= 0 && original_img2(i, j) == 0  % 白 白 黑
                        img1(new_img_row + 1, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    end
                    
            end
        end
    end

end



% img_merge: 使用按位与操作合并两个图像
% 输入参数:
%   - img1: 第一个输入图像
%   - img2: 第二个输入图像
% 输出参数:
%   - img: 合并后的图像（与输入图像尺寸相同）
function img = img_merge(img1, img2)
    img_size = size(img1); % 获取图像尺寸（假设两个图像尺寸相同）
    disp("输入图像img1的尺寸：");
    disp(img_size);
 
    x = img_size(1);  % 获取图像高度
    y = img_size(2);  % 获取图像宽度
    disp("图像第一维度尺寸：");
    disp(x);
    disp("图像第二维度尺寸：");
    disp(y);
 
    img = 255 * ones(x, y); % 初始化全白图像
    disp("合并后图像的尺寸：");
    disp(size(img));
 
    for i = 1 : x
        for j = 1 : y
            img(i, j) = bitand(img1(i, j), img2(i, j));  % 执行按位与操作
        end
    end
 
    disp("最终合并图像的尺寸：");
    disp(size(img));
end