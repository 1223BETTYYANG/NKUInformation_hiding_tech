%DCT_C
a=imread('lena.png');
b=rgb2gray(a); %转换为灰度图像

figure(1);
imshow(b);
title('灰度图像');
imwrite(b,'灰度图像l.jpg');

I=im2bw(b);
figure(2);
imwrite(I,'二值图像l.jpg')

c=dct2(I);     %离散余弦变换
imshow(c);
title('DCT变换系数');
imwrite(c,'DCT变换系数l.jpg');

figure;
mesh(c);
title('DCT变换系数(立体图)');
%imwrite(d,'DCT变换系数（立体图）DOG.jpg');
