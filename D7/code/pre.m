% prechange
% 处理第一张图片(800x800灰度图)
x = imread("PP.jpg");
y = imresize(x, [800, 800]);  % 修改尺寸为800x800
gx = rgb2gray(y);
imwrite(gx, 'gPP.png');

% 处理第二张图片(400x400灰度图)
m = imread("dog.jpg");
mm = imresize(m, [400, 400]);  % 修改尺寸为400x400
gm = rgb2gray(mm);
imwrite(gm, 'gdog.png');        % 直接保存灰度图