function SuperpositionBin()

origin = imread("origin.png");
origin1 = imread("car.png");
origin2 = imread("shape.png");
[image1,image2] = divide(origin,origin1,origin2);
figure, imshow(origin), title('原图');
figure, imshow(origin1), title('分存图1');
figure, imshow(origin2), title('分存图2');
figure, imshow(image1), title('伪装图像1');
figure, imshow(image2), title('伪装图像2');

recoverorigin = merge(image1, image2);
figure, imshow(recoverorigin), title('恢复后的图像');
end

function [image1,image2] = divide(origin,origin1,origin2)
Size=size(origin);
x=Size(1);
y=Size(2);
image1 = 255 * ones(2 * x, 2 * y);
image2 = 255 * ones(2 * x, 2 * y);

for i = 1:x
    for j = 1:y
        key = randi(4);
        new_row=2*(i-1)+1;
        new_col=2*(j-1)+1;
        switch key
            case 1
                if origin(i,j)==0 && origin1(i,j)==0 && origin2(i,j)==0  %黑  黑  黑
                    image1(new_row,new_col)=0;
                    image1(new_row+1,new_col)=0;
                    image1(new_row+1,new_col+1)=0;

                    image2(new_row,new_col+1)=0;
                    image2(new_row+1,new_col)=0;
                    image2(new_row+1,new_col+1)=0;

                elseif origin(i,j)==0 && origin1(i,j)==0 && origin2(i,j)~=0  %黑 黑 白
                    image1(new_row,new_col+1)=0;
                    image1(new_row+1,new_col)=0;
                    image1(new_row+1,new_col+1)=0;

                    image2(new_row,new_col)=0;
                    image2(new_row,new_col+1)=0;

                elseif origin(i,j)==0 && origin1(i,j)~=0 && origin2(i,j)==0  %黑 白 黑
                    image1(new_row+1,new_col)=0;
                    image1(new_row+1,new_col+1)=0;

                    image2(new_row,new_col)=0;
                    image2(new_row,new_col+1)=0;
                    image2(new_row+1,new_col)=0;

                elseif origin(i,j)==0 && origin1(i,j)~=0 && origin2(i,j)~=0  %黑 白 白
                    image1(new_row+1,new_col)=0;
                    image1(new_row+1,new_col+1)=0;

                    image2(new_row,new_col)=0;
                    image2(new_row,new_col+1)=0;

                elseif origin(i,j)~=0 && origin1(i,j)==0 && origin2(i,j)==0  %白 黑 黑
                    image1(new_row,new_col)=0;
                    image1(new_row,new_col+1)=0;
                    image1(new_row+1,new_col)=0;

                    image2(new_row,new_col)=0;
                    image2(new_row,new_col+1)=0;
                    image2(new_row+1,new_col)=0;

                elseif origin(i,j)~=0 && origin1(i,j)==0 && origin2(i,j)~=0  %白 黑 白
                    image1(new_row,new_col)=0;
                    image1(new_row,new_col+1)=0;
                    image1(new_row+1,new_col)=0;

                    image2(new_row,new_col)=0;
                    image2(new_row,new_col+1)=0;

                elseif origin(i,j)~=0 && origin1(i,j)~=0 && origin2(i,j)~=0  %白 白 白
                    image1(new_row,new_col+1)=0;
                    image1(new_row+1,new_col+1)=0;

                    image2(new_row,new_col)=0;
                    image2(new_row,new_col+1)=0;

                elseif origin(i,j)~=0 && origin1(i,j)~=0 && origin2(i,j)==0  %白 白 黑
                    image1(new_row+1,new_col)=0;
                    image1(new_row+1,new_col+1)=0;

                    image2(new_row,new_col+1)=0;
                    image2(new_row+1,new_col)=0;
                    image2(new_row+1,new_col+1)=0;

                end
            case 2
                if origin(i,j)==0 && origin1(i,j)==0 && origin2(i,j)==0  %黑  黑  黑
                    image1(new_row,new_col)=0;
                    image1(new_row,new_col+1)=0;
                    image1(new_row+1,new_col)=0;

                    image2(new_row,new_col)=0;
                    image2(new_row,new_col+1)=0;
                    image2(new_row+1,new_col+1)=0;

                elseif origin(i,j)==0 && origin1(i,j)==0 && origin2(i,j)~=0  %黑 黑 白
                    image1(new_row,new_col)=0;
                    image1(new_row+1,new_col)=0;
                    image1(new_row+1,new_col+1)=0;

                    image2(new_row,new_col+1)=0;
                    image2(new_row+1,new_col+1)=0;

                elseif origin(i,j)==0 && origin1(i,j)~=0 && origin2(i,j)==0  %黑 白 黑
                    image1(new_row,new_col)=0;
                    image1(new_row+1,new_col)=0;

                    image2(new_row,new_col+1)=0;
                    image2(new_row+1,new_col)=0;
                    image2(new_row+1,new_col+1)=0;

                elseif origin(i,j)==0 && origin1(i,j)~=0 && origin2(i,j)~=0  %黑 白 白
                    image1(new_row,new_col)=0;
                    image1(new_row+1,new_col)=0;

                    image2(new_row,new_col+1)=0;
                    image2(new_row+1,new_col+1)=0;

                elseif origin(i,j)~=0 && origin1(i,j)==0 && origin2(i,j)==0  %白 黑 黑
                    image1(new_row,new_col)=0;
                    image1(new_row,new_col+1)=0;
                    image1(new_row+1,new_col+1)=0;

                    image2(new_row,new_col)=0;
                    image2(new_row,new_col+1)=0;
                    image2(new_row+1,new_col+1)=0;

                elseif origin(i,j)~=0 && origin1(i,j)==0 && origin2(i,j)~=0  %白 黑 白
                    image1(new_row,new_col)=0;
                    image1(new_row,new_col+1)=0;
                    image1(new_row+1,new_col+1)=0;

                    image2(new_row,new_col)=0;
                    image2(new_row+1,new_col+1)=0;

                elseif origin(i,j)~=0 && origin1(i,j)~=0 && origin2(i,j)~=0  %白 白 白
                    image1(new_row,new_col)=0;
                    image1(new_row,new_col+1)=0;

                    image2(new_row,new_col)=0;
                    image2(new_row+1,new_col+1)=0;

                elseif origin(i,j)~=0 && origin1(i,j)~=0 && origin2(i,j)==0  %白 白 黑
                    image1(new_row,new_col)=0;
                    image1(new_row,new_col+1)=0;

                    image2(new_row,new_col)=0;
                    image2(new_row,new_col+1)=0;
                    image2(new_row+1,new_col+1)=0;

                end

            case 3
                if origin(i,j)==0 && origin1(i,j)==0 && origin2(i,j)==0  %黑  黑  黑
                    image1(new_row,new_col+1)=0;
                    image1(new_row+1,new_col)=0;
                    image1(new_row+1,new_col+1)=0;

                    image2(new_row,new_col)=0;
                    image2(new_row+1,new_col)=0;
                    image2(new_row+1,new_col+1)=0;

                elseif origin(i,j)==0 && origin1(i,j)==0 && origin2(i,j)~=0  %黑 黑 白
                    image1(new_row,new_col)=0;
                    image1(new_row,new_col+1)=0;
                    image1(new_row+1,new_col+1)=0;

                    image2(new_row+1,new_col)=0;
                    image2(new_row+1,new_col+1)=0;

                elseif origin(i,j)==0 && origin1(i,j)~=0 && origin2(i,j)==0  %黑 白 黑
                    image1(new_row,new_col)=0;
                    image1(new_row,new_col+1)=0;

                    image2(new_row,new_col)=0;
                    image2(new_row+1,new_col)=0;
                    image2(new_row+1,new_col+1)=0;

                elseif origin(i,j)==0 && origin1(i,j)~=0 && origin2(i,j)~=0  %黑 白 白
                    image1(new_row,new_col)=0;
                    image1(new_row,new_col+1)=0;

                    image2(new_row+1,new_col)=0;
                    image2(new_row+1,new_col+1)=0;

                elseif origin(i,j)~=0 && origin1(i,j)==0 && origin2(i,j)==0  %白 黑 黑
                    image1(new_row,new_col+1)=0;
                    image1(new_row+1,new_col)=0;
                    image1(new_row+1,new_col+1)=0;

                    image2(new_row,new_col+1)=0;
                    image2(new_row+1,new_col)=0;
                    image2(new_row+1,new_col+1)=0;

                elseif origin(i,j)~=0 && origin1(i,j)==0 && origin2(i,j)~=0  %白 黑 白
                    image1(new_row,new_col)=0;
                    image1(new_row+1,new_col)=0;
                    image1(new_row+1,new_col+1)=0;

                    image2(new_row+1,new_col)=0;
                    image2(new_row+1,new_col+1)=0;

                elseif origin(i,j)~=0 && origin1(i,j)~=0 && origin2(i,j)~=0  %白 白 白
                    image1(new_row,new_col+1)=0;
                    image1(new_row+1,new_col)=0;

                    image2(new_row+1,new_col)=0;
                    image2(new_row+1,new_col+1)=0;

                elseif origin(i,j)~=0 && origin1(i,j)~=0 && origin2(i,j)==0  %白 白 黑
                    image1(new_row,new_col+1)=0;
                    image1(new_row+1,new_col)=0;

                    image2(new_row,new_col)=0;
                    image2(new_row,new_col+1)=0;
                    image2(new_row+1,new_col)=0;

                end

            case 4
                if origin(i,j)==0 && origin1(i,j)==0 && origin2(i,j)==0  %黑  黑  黑
                    image1(new_row,new_col)=0;
                    image1(new_row,new_col+1)=0;
                    image1(new_row+1,new_col+1)=0;

                    image2(new_row,new_col)=0;
                    image2(new_row,new_col+1)=0;
                    image2(new_row+1,new_col)=0;

                elseif origin(i,j)==0 && origin1(i,j)==0 && origin2(i,j)~=0  %黑 黑 白
                    image1(new_row,new_col)=0;
                    image1(new_row,new_col+1)=0;
                    image1(new_row+1,new_col)=0;

                    image2(new_row,new_col)=0;
                    image2(new_row+1,new_col+1)=0;

                elseif origin(i,j)==0 && origin1(i,j)~=0 && origin2(i,j)==0  %黑 白 黑
                    image1(new_row,new_col+1)=0;
                    image1(new_row+1,new_col)=0;

                    image2(new_row,new_col)=0;
                    image2(new_row,new_col+1)=0;
                    image2(new_row+1,new_col+1)=0;

                elseif origin(i,j)==0 && origin1(i,j)~=0 && origin2(i,j)~=0  %黑 白 白
                    image1(new_row,new_col+1)=0;
                    image1(new_row+1,new_col)=0;

                    image2(new_row,new_col)=0;
                    image2(new_row+1,new_col+1)=0;

                elseif origin(i,j)~=0 && origin1(i,j)==0 && origin2(i,j)==0  %白 黑 黑
                    image1(new_row,new_col)=0;
                    image1(new_row+1,new_col)=0;
                    image1(new_row+1,new_col+1)=0;

                    image2(new_row,new_col)=0;
                    image2(new_row+1,new_col)=0;
                    image2(new_row+1,new_col+1)=0;

                elseif origin(i,j)~=0 && origin1(i,j)==0 && origin2(i,j)~=0  %白 黑 白
                    image1(new_row,new_col+1)=0;
                    image1(new_row+1,new_col)=0;
                    image1(new_row+1,new_col+1)=0;

                    image2(new_row,new_col+1)=0;
                    image2(new_row+1,new_col+1)=0;

                elseif origin(i,j)~=0 && origin1(i,j)~=0 && origin2(i,j)~=0  %白 白 白
                    image1(new_row+1,new_col)=0;
                    image1(new_row+1,new_col+1)=0;

                    image2(new_row,new_col+1)=0;
                    image2(new_row+1,new_col+1)=0;

                elseif origin(i,j)~=0 && origin1(i,j)~=0 && origin2(i,j)==0  %白 白 黑
                    image1(new_row+1,new_col)=0;
                    image1(new_row+1,new_col+1)=0;

                    image2(new_row,new_col)=0;
                    image2(new_row+1,new_col)=0;
                    image2(new_row+1,new_col+1)=0;

                end


        end
    end
end

end

function image = merge(image1,image2)
Size=size(image1);
x=Size(1);
y=Size(2);
image=255 * ones(x, y);

for i=1:x
    for j=1:y
        image(i,j)=image1(i,j)&image2(i,j);
    end
end

end