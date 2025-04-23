function VC_RGB()
%%%% 图片处理部分
% 读取彩色图片
img = imread('RGB_ver.png');

% 分解 R、G、B 通道
R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);

subplot(2,4,1);
imshow(img);
title('原始彩色图片');

% 对每个通道进行半色调处理
halftone_R = s_ht(R);
halftone_G = s_ht(G);
halftone_B = s_ht(B);

% 合并半色调后的 R、G、B，形成彩色半色调图像
halftone = cat(3, halftone_R, halftone_G, halftone_B);
subplot(2,4,2);
imshow(halftone);
title('彩色半色调合并图像');

% 对每个通道进行可视密码学拆分
[image1_R, image2_R] = ht_divide(halftone_R);
[image1_G, image2_G] = ht_divide(halftone_G);
[image1_B, image2_B] = ht_divide(halftone_B);

% 合并 R、G、B 生成两张彩色子图
image1 = cat(3, image1_R, image1_G, image1_B);
image2 = cat(3, image2_R, image2_G, image2_B);

subplot(2,4,5);
imshow(image1);
title('伪装彩色图像1');

subplot(2,4,6);
imshow(image2);
title('伪装彩色图像2');

% 保存伪装图像
imwrite(image1, 'image1_color.png');
imwrite(image2, 'image2_color.png');

%%%% 还原图片
rebuild_R = ht_rb(image1_R, image2_R);
rebuild_G = ht_rb(image1_G, image2_G);
rebuild_B = ht_rb(image1_B, image2_B);

% 合并 R、G、B 生成还原的彩色图像
rebuild = cat(3, rebuild_R, rebuild_G, rebuild_B);

subplot(2,4,7);
imshow(rebuild);
title('恢复的彩色图像');

% 保存还原图像
imwrite(rebuild, 'rebuild_color.png');

end


%误差扩散法
function image = s_ht(gray)
% 读取灰度图片
%gray = double(gray); 
%[x, y] = size(gray); % 获取图像尺寸
%halftone = zeros(x, y); % 初始化二值化图像
Size = size(gray);
x = Size(1);
y = Size(2);
% 误差扩散系数
for m = 1:x
    for n = 1:y
        if gray(m,n)>127
            out = 255;
        else
            out = 0;
        end
        error = gray(m,n) - out;
        if n > 1 && n < 255 && m < 255
            gray(m,n + 1) =gray(m,n + 1) + error * 7/16.0;  %右方
            gray(m + 1,n) = gray(m + 1,n) + error * 5/16.0;  %下方
            gray(m + 1,n - 1) = gray(m + 1,n - 1) + error * 3/16.0;  %左下方
            gray(m + 1,n + 1) = gray(m + 1,n + 1) + error * 1/16.0;  %右下方
            gray(m,n) = out;
        else
            gray(m,n) = out;
        end
    end
end
image = gray;
end

%可视密码学-拆图
function [image1, image2] = ht_divide(halftone)
%1->4 两边皆翻倍
Size = size(halftone);
x = Size(1);
y = Size(2);
%All white
image1 = zeros(2*x,2*y);
image1(:,:) = 255;
image2 = zeros(2*x,2*y);
image2(:,:) = 255;

for i = 1:x
    for j = 1:y
        %翻倍子图的对应四格左上角像素点初始化
        db_x = 1 + 2*(i - 1);
        db_y = 1 + 2*(j - 1);
        %按照课件-img1 three kinds of matches
        key = randi(3);
        switch key
            case 1
            %bb
            %ww
                image1(db_x,db_y) = 0; 
                image1(db_x,db_y + 1) = 0;
                %result=b
                if halftone(i,j) == 0
                    %ww
                    %bb
                    image2(db_x + 1,db_y) = 0; 
                    image2(db_x + 1,db_y + 1) = 0;
                else
                    %wb
                    %wb
                    image2(db_x,db_y + 1) = 0; 
                    image2(db_x + 1,db_y + 1) = 0;

                end
            case 2
            %bw
            %wb
                image1(db_x,db_y) = 0; 
                image1(db_x + 1,db_y + 1) = 0;
                %result=b
                if halftone(i,j) == 0
                    %wb
                    %bw
                    image2(db_x,db_y + 1) = 0; 
                    image2(db_x + 1,db_y) = 0;
                else
                    %bw
                    %bw
                    image2(db_x,db_y) = 0; 
                    image2(db_x + 1,db_y) = 0;
                end
            case 3
            %bw
            %bw
                image1(db_x,db_y) = 0; 
                image1(db_x + 1,db_y) = 0;
                %result=b
                if halftone(i,j) == 0
                    %wb
                    %wb
                    image2(db_x,db_y + 1) = 0; 
                    image2(db_x + 1,db_y + 1) = 0;
                else
                    %bb
                    %ww
                    image2(db_x,db_y) = 0; 
                    image2(db_x,db_y + 1) = 0;
                end
        end
    end
end

end

%可视密码学-还原
function image = ht_rb(image1, image2)
Size = size(image1);
x = Size(1);
y = Size(2);
%All white
image=zeros(x,y);
image(:,:)=255;
for i = 1:x
    for j = 1:y
        image(i,j) = image1(i,j) & image2(i,j);
    end
end

end
