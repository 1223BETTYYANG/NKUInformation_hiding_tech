% 图像pre处理
x = imread("lena.png");
y = imresize(x, [256, 256]);
gx = rgb2gray(y);
imwrite(gx, 'glena.png'); 
m = imread("NK.jpg");
mm = imresize(m, [256, 256]);
gm = rgb2gray(mm);
km = im2bw(gm);
imwrite(km, '2NK.png'); 