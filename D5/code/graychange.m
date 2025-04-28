img = imread("lena.png");
gray_img = rgb2gray(img);
imwrite(gray_img, 'glena.png');
img = imread("dog.jpg");
gray_img = rgb2gray(img);
imwrite(gray_img, 'gdog.jpg');