img = imread("gdog.jpg");
% 获取图像 img 的尺寸
[m,n]=size(img);
layer_image=zeros(m,n);
% 参考飞书文档范例
for layer=1:8
    for i=1:m
        for j=1:n
            % 使用 bitget 函数从图像的每个像素中提取特定位（layer 指定的位），
            % 并将其存储在矩阵 layer_image 中的相应位置。
            layer_image(i,j)=bitget(img(i,j),layer);
        end
    end
    figure
    % imshow-[min(I(:)) max(I(:))] 作为显示范围(将I中的最小值显示为黑色，将最大值显示为白色)。
    imshow(layer_image,[]);
    title(['图像第',num2str(layer),'层位平面']);
    % save
    filename = ['Dog第', num2str(layer), '层位平面.jpg'];
    imwrite(layer_image, filename);

end