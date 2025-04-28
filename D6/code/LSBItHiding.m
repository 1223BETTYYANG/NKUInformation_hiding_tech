function LSBItHiding()
    x = imread("glena.png");
    SN = 2211819;
    %imshow(x, [])
    WaterMarked=Embedding(x, SN);
    message = Decode(WaterMarked);
    str=['学号是：',num2str(message)];
    disp(str);
end

function WaterMarked = Embedding(origin, watermark)
    [Mc, Nc] = size(origin);
    WaterMarked = uint8(zeros(size(origin)));
    for i = 1:Mc
        for j = 1:Nc
            if i == 1 && j <= 24
                bit = bitget(watermark, j);
                WaterMarked(i, j) = bitset(origin(i, j), 1, bit);
            else
                WaterMarked(i, j) = origin(i, j);
            end
        end
    end
    
    imwrite(WaterMarked, 'lsbint_watermarked.png', 'png');
    figure;
    imshow(WaterMarked,[]);
    title("watermarked_image_int");
end

function message = Decode(WaterMarked)
    message = 0;
    for j = 1:24
        bit = bitget(WaterMarked(1, j),1);
        message = bitset(message, j,bit);
    end
end