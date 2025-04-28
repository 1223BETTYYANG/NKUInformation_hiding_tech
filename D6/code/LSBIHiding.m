function LSBIHiding()
    x = imread("glena.png");      %原图像
    m = imread("2NK.png");        %水印图像
    WaterMarked = Embedding(x, m);%嵌入水印
    imwrite(WaterMarked, 'lsbi_watermark.png', 'png');
    figure;
    imshow(WaterMarked, []);
    WaterMark = Decode(WaterMarked);
    imwrite(WaterMark, 'recovered_iwatermark.png', 'png');
    figure;
    imshow(WaterMark, []);
end

function WaterMarked = Embedding(origin, watermark)
    [Mc, Nc] = size(origin);
    WaterMarked = uint8(zeros(size(origin)));
    for i = 1:Mc
        for j = 1:Nc
            WaterMarked(i, j) = bitset(origin(i, j),1,watermark(i, j));
        end
    end
    % imwrite(WaterMarked, 'lsbi_watermark.png', 'png');
    % figure;
    % imshow(WaterMarked, []);
end

function WaterMark = Decode(WaterMarked)
    [Mc, Nc] = size(WaterMarked);
    WaterMark = uint8(zeros(size(WaterMarked)));
 
    for i = 1:Mc
        for j = 1:Nc
            WaterMark(i, j) = bitget(WaterMarked(i, j), 1);
        end
    end
    % imwrite(WaterMark, 'recovered_iwatermark.png', 'png');
    % figure;
    % imshow(WaterMark, []);
end