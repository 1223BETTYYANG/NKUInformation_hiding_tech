clear;
clc;
close all;

% 参数设置
wav_path = "input.wav";
image_path = "image.png";
output_path = "audio_with_img.wav";

% 嵌入图像
[n_row, n_col] = embed_image_in_audio(wav_path, image_path, output_path);

% 提取图像
img_extracted = extract_image_from_audio(output_path, [n_row, n_col]);

% 显示结果
original_img = im2gray(imread(image_path));
original_img = imbinarize(original_img);

[cover_y, Fs_cover] = audioread(wav_path);
cover_x = (0:length(cover_y)-1) / Fs_cover;
[audio_with_img_y, Fs_audio_with_img] = audioread(output_path);
audio_with_img_x = (0:length(audio_with_img_y)-1) / Fs_audio_with_img;

figure;
plot(cover_x, cover_y);
xlabel('Time / (s)'); ylabel('Amplitude');
title("原音频");

figure;
plot(audio_with_img_x, audio_with_img_y);
xlabel('Time / (s)'); ylabel('Amplitude');
title("嵌入图像后的音频");

figure;
imshow(original_img);
title("嵌入前的图像");

figure;
imshow(img_extracted);
title("提取出的图像");

% 细节对比
figure;
axis_set = [0.5, 1.5, -0.15, 0.15];
plot(cover_x, cover_y);
axis(axis_set);
xlabel('Time / (s)'); ylabel('Amplitude');
title("原音频（细节）");

figure;
plot(audio_with_img_x, audio_with_img_y);
axis(axis_set);
xlabel('Time / (s)'); ylabel('Amplitude');
title("嵌入图像后的音频（细节）");
function [n_row, n_col] = embed_image_in_audio(audio_file, image_file, output_file)
    % 读取音频
    [cover, Fs] = audioread(audio_file);
    cover = cover(:, 1); % 使用单通道

    % 转换为整数格式（int16）
    cover_int = int16(cover * 32768);

    % 读取图像并预处理
    payload = imread(image_file);
    payload = im2gray(payload);
    payload = imbinarize(payload);
    [n_row, n_col] = size(payload);
    payload_len = n_row * n_col;

    assert(payload_len <= length(cover_int), "Payload too large for cover audio!");

    % 序列化图像
    payload_seq = payload(:);

    % LSB 替换
    audio_with_img = cover_int;
    audio_with_img(1:payload_len) = bitset(cover_int(1:payload_len), 1, payload_seq);

    % 保存为WAV
    audio_with_img = double(audio_with_img) / 32768; % 转换为[-1, 1]范围
    audiowrite(output_file, audio_with_img, Fs);
end
function img = extract_image_from_audio(audio_file, image_size)
    [audio_data, ~] = audioread(audio_file);
    audio_data = audio_data(:, 1); % 单通道
    audio_int = int16(audio_data * 32768);

    payload_len = prod(image_size);
    lsb_bits = bitget(audio_int(1:payload_len), 1);
    img = reshape(logical(lsb_bits), image_size);
end
