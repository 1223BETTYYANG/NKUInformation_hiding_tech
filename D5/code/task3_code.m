img = imread("gdog.jpg");
[m,n]=size(img);
for k=1:7
    temp_img = img;
    % choose to remove first k-layers
    for ch=1:k
        for i=1:m
            for j=1:n
                % 设置为0
                temp_img(i,j) = bitset(temp_img(i,j), ch, 0);
            end
        end
    end
    figure;
    imshow(temp_img,[]);
    title(['去除前',num2str(k),'层位平面']);

    filename = ['dog去除前', num2str(k), '层位平面.png'];
    imwrite(temp_img, filename);
end