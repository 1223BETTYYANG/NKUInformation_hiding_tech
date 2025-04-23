%DFT
b=imread('dog.jpg');
figure;
gray_b = rgb2gray(b);        % 转换为灰度图
I=imbinarize(gray_b);        % 实验中使用的版本为R2023a,无法使用参考文档中的函数
imshow(I);
title('二值图像');
figure;
fa=fft2(I);                  %使用fft函数进行快速傅立叶变换
ffa=fftshift(fa);
%fftshift函数调整fft函数的输出顺序，将零频位置移到频谱的中心
image(abs(ffa));
title('DFT幅度谱');
figure;
%画网格曲面图
mesh(abs(ffa));
title('DFT幅度谱的能量分布');