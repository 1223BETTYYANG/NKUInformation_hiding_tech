function shamir_secret_share()
    clc; clear; close all;

    %------------------------%
    % 1. 参数设置与读入图像  %
    %------------------------%
    p = 257;  % 选取257作为大质数
    
    % 读入图像
    img = imread('Lady.png');
    [rows, cols, channelNum] = size(img);

    % 将图像转换为 double 方便后续做 mod 运算
    img = double(img);

    % 判断是否彩色
    if channelNum == 3
        disp('检测到彩色图像，将对 R、G、B 三个通道分别进行分享。');
    else
        disp('检测到灰度图像，将对单通道进行分享。');
    end

    % 由用户输入 t 和 n
    t = input('请输入阈值 t（参与恢复的最少分片数）: ');
    n = input('请输入生成的分片总数 n: ');

    if t > n
        error('t 不能大于 n，请重新运行程序并保证 t <= n。');
    end

    %------------------------%
    % 2. 生成分片并保存     %
    %------------------------%
    disp('开始生成分片...');
    % 使用 cell 数组存储分片图像
    shareCells = cell(1, n);

    % 对每个通道分别做 Shamir 分享
    for c = 1:channelNum
        % 取第 c 个通道
        channelData = img(:,:,c);

        % 初始化该通道的 n 份分片存储空间,每个分片与原图同尺寸
        channelShares = zeros(rows, cols, n);

        % 针对图像中每个像素进行秘密分享
        for r = 1:rows
            for col = 1:cols
                % 原图像素值 a0
                a0 = mod(round(channelData(r, col)), p);

                % 产生多项式系数 a1, a2, ..., a_{t-1}（随机）
                % a0 即为原像素值
                coeffs = [a0; randi([0, p-1], t-1, 1)];

                % 计算 n 个分片值 f(1), f(2), ..., f(n)
                for x = 1:n
                    % 多项式求值
                    fx = 0;
                    for k = 0:(t-1)
                        fx = fx + coeffs(k+1) * (x^k);
                    end
                    % 取 mod p
                    fx = mod(fx, p);
                    channelShares(r, col, x) = fx;
                end
            end
        end

        % 将该通道的分片叠加到 shareCells 对应位置
        for x = 1:n
            if isempty(shareCells{x})
                shareCells{x} = zeros(rows, cols, channelNum);
            end
            shareCells{x}(:,:,c) = channelShares(:,:,x);
        end
    end

    % 保存 n 个分片图像
    disp('开始保存分片图像...');

    % 获取当前脚本所在目录
    scriptFullPath = mfilename('fullpath'); 
    [scriptPath, ~, ~] = fileparts(scriptFullPath);
    shareSavePath = scriptPath;
    
    for x = 1:n
        shareImg = shareCells{x};
        % 转回 uint16 （避免 256 数据丢失）以保存图像
        shareImg = uint16(mod(round(shareImg), p));
        shareFileName = fullfile(shareSavePath, sprintf('Share_%d.png', x));
        imwrite(shareImg, shareFileName);
    end
    
    disp('分片图像保存完毕。');

    %------------------------%
    % 3. 用户选择分片并恢复  %
    %------------------------%
    disp('现在进行图像恢复：');
    numUsedShares = input('请输入要合并的分片数（需 >= t）: ');
    if numUsedShares < t
        error('所选分片数必须大于或等于 t。程序终止。');
    end

    % 让用户选择分片序号
    disp(['可选分片序号范围为 1 到 ', num2str(n)]);
    usedShareIdx = zeros(1, numUsedShares);
    for i = 1:numUsedShares
        idx = input(['请输入第 ', num2str(i), ' 个分片的序号: ']);
        if idx < 1 || idx > n
            error('输入的分片序号超出范围。');
        end
        usedShareIdx(i) = idx;
    end
    usedShareIdx = unique(usedShareIdx);  % 去重，防止重复
    if length(usedShareIdx) < t
        error('实际可用的分片数少于 t，无法恢复。程序终止。');
    end

    % 读入选择的分片图像
    usedSharesData = cell(1, length(usedShareIdx));
    for i = 1:length(usedShareIdx)
        shareFile = fullfile(shareSavePath, sprintf('Share_%d.png', usedShareIdx(i)));
        usedSharesData{i} = double(imread(shareFile));
    end

    % 恢复图像
    disp('开始利用 Lagrange 插值进行图像恢复...');
    recoveredImg = zeros(rows, cols, channelNum);

    % x 坐标就是选定分片的序号
    X = usedShareIdx;
    tActual = length(X);  % 实际参与的分片数

    % 构造用于插值的函数，计算给定 x0 时的插值值
    % Lagrange 多项式：f(x0) = sum(y_j * l_j(x0)), 其中
    % l_j(x0) = product( (x0 - X_m)/(X_j - X_m) ), m != j
    % 这里需要在 mod p 意义下做乘法逆

    for r = 1:rows
        for c = 1:cols
            for ch = 1:channelNum
                % Y_j：对应选定分片的像素值
                Y = zeros(1, tActual);
                for j = 1:tActual
                    Y(j) = usedSharesData{j}(r, c, ch);
                end

                % 计算插值
                recoveredVal = 0;
                for j = 1:tActual
                    % 计算 l_j(x0)，这里 x0 = 0 用于恢复 a0
                    % 但是对整张图像，我们想要原像素值，相当于 f(0) = a0
                    % Shamir 方案中，a0 就是秘密(像素值)。所以直接插值到 x=0
                    numerator = 1;
                    denominator = 1;
                    for m = 1:tActual
                        if m ~= j
                            numerator   = mod(numerator   * (0 - X(m)), p);
                            denominator = mod(denominator * (X(j) - X(m)), p);
                        end
                    end
                    % 乘以模逆
                    l_j = mod(numerator * modInverse(denominator, p), p);
                    recoveredVal = mod(recoveredVal + Y(j) * l_j, p);
                end

                recoveredImg(r, c, ch) = recoveredVal;
            end
        end
    end

    % 转为 uint8
    recoveredImg = uint8(mod(round(recoveredImg), p));

    % 保存并显示恢复结果
    recoveredFileName = fullfile(shareSavePath, 'Recovered_Image.png');
    imwrite(recoveredImg, recoveredFileName);
    figure; imshow(recoveredImg);
    title('恢复后的图像');
    disp(['图像恢复完成，已保存为： ', recoveredFileName]);
end


%------------------------%
%   求模逆的辅助函数     %
%------------------------%
function invA = modInverse(a, p)
    % 计算 a 在 mod p 下的乘法逆，这里使用扩展欧几里得算法
    [g, x, ~] = extendedGCD(a, p);
    if g ~= 1
        error('在 mod %d 下，%d 不存在乘法逆。', p, a);
    else
        invA = mod(x, p);
    end
end

function [g, x, y] = extendedGCD(a, b)
    % 扩展欧几里得算法，返回 gcd(a,b) = g, 并满足 ax + by = g
    if b == 0
        g = a; x = 1; y = 0;
    else
        [g, x1, y1] = extendedGCD(b, mod(a, b));
        x = y1;
        y = x1 - floor(a/b)*y1;
    end
end
