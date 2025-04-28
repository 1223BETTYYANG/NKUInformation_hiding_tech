img = imread("gdog.jpg");
[m,n]=size(img);
low=zeros(m,n);
high=zeros(m,n);

for k=1:7
    % 迭代处理低位平面
    for ch=1:k
        for i=1:m
            for j=1:n
                low(i,j)=bitset(low(i,j),ch,bitget(img(i,j),ch));
            end
        end
    end
    % 迭代处理高位平面
    for ch=k+1:8
        for i=1:m
            for j=1:n
                high(i,j)=bitset(high(i,j),ch,bitget(img(i,j),ch));
            end
        end
    end

figure;
subplot(1,2,1);
imshow(low,[]);
title(['第1-',num2str(k),'个位平面']);
subplot(1,2,2);
imshow(high,[]);
title(['第',num2str(k+1),'-8个位平面']);
end