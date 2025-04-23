function main()
    clear;
    clc;
    close all;
    % 读取载体音频文件
    [header, cover, bits_per_sample] = wav_read("audio/cover.wav");
    % 按位读取隐写音频文件
    fid = fopen("audio/payload.wav", "r"); 
    payload = fread(fid, 'ubit1'); % 读取为无符号位数据
    fclose(fid); 

    % 检查确保：隐写数据长度 <= 载体数据长度
    payload_len = length(payload); 
    assert(payload_len <= length(cover), "隐写数据长度不能超过载体数据长度！");

    % 将隐写数据嵌入到载体音频的 LSB
    audio_with_info = cover; % 复制载体音频数据
    audio_with_info(1:payload_len) = bitset(cover(1:payload_len), 1, payload); % 替换 LSB

    % 将嵌入隐写数据的音频保存为新的 WAV 文件
    fid = fopen("audio/audio_with_info.wav", "w");
    fwrite(fid, header, 'uint8'); % 写入头信息
    fwrite(fid, audio_with_info, ['uint', num2str(bits_per_sample)]); % 写入音频数据
    fclose(fid);

    % 从嵌入隐写数据的音频中提取隐写数据
    [header, audio_with_info, bits_per_sample] = wav_read("audio/audio_with_info.wav");
    info = bitget(audio_with_info, 1); % 提取 LSB 位

    % 获取隐写数据的真实长度 (从嵌入的信息中解析长度)
    info_len_bits = info(33:64); % 假设长度信息存储在特定位置 (例如第33到64位)
    info_len = uint32(0); % 初始化长度变量
    for i = 1:32
        info_len = bitset(info_len, i, info_len_bits(i)); % 逐位设置长度
    end
    info_len = info_len + 8; % 转换为字节长度 (加上额外的头部信息长度)
    info_len = info_len * 8; % 转换为位长度

    % 保存提取的隐写数据为新的 WAV 文件
    fid = fopen("audio/info.wav", "w");
    fwrite(fid, info(1:info_len), 'ubit1'); % 写入提取的隐写数据
    fclose(fid);

    % 读取并显示结果音频波形
    [cover_y, Fs_cover] = audioread("audio/cover.wav");
    cover_x = (0:length(cover_y)-1) / Fs_cover; % 时间轴
    [payload_y, Fs_payload] = audioread("audio/payload.wav");
    payload_x = (0:length(payload_y)-1) / Fs_payload; % 时间轴
    [audio_with_info_y, Fs_audio_with_info] = audioread("audio/audio_with_info.wav");
    audio_with_info_x = (0:length(audio_with_info_y)-1) / Fs_audio_with_info; % 时间轴
    [info_y, Fs_info] = audioread("audio/info.wav");
    info_x = (0:length(info_y)-1) / Fs_info; % 时间轴

% 绘制音频波形 (第一组)
figure(1);
subplot(2, 2, 1);
plot(cover_x, cover_y);
xlabel('时间 / (秒)'); ylabel('幅度');
title("载体音频");

subplot(2, 2, 2);
plot(payload_x, payload_y);
xlabel('时间 / (秒)'); ylabel('幅度');
title("隐藏音频");

subplot(2, 2, 3);
plot(audio_with_info_x, audio_with_info_y);
xlabel('时间 / (秒)'); ylabel('幅度');
title("含信息音频");

subplot(2, 2, 4);
plot(info_x, info_y);
xlabel('时间 / (秒)'); ylabel('幅度');
title("提取音频");

% 绘制音频波形 (第二组，带固定坐标轴范围)
figure(2);
axis_set = [0.5, 1, -1, 1]; % 自定义坐标轴范围

subplot(2, 2, 1);
plot(cover_x, cover_y);
axis(axis_set);
xlabel('时间 / (秒)'); ylabel('幅度');
title("载体音频");

subplot(2, 2, 2);
plot(payload_x, payload_y);
axis(axis_set);
xlabel('时间 / (秒)'); ylabel('幅度');
title("隐藏音频");

subplot(2, 2, 3);
plot(audio_with_info_x, audio_with_info_y);
axis(axis_set);
xlabel('时间 / (秒)'); ylabel('幅度');
title("含信息音频");

subplot(2, 2, 4);
plot(info_x, info_y);
axis(axis_set);
xlabel('时间 / (秒)'); ylabel('幅度');
title("提取音频");
end

function [header, data, bits_per_sample] = wav_read(file_path)
    fid = fopen(file_path, "r"); % 只读模式打开WAV文件
    header = fread(fid, 78, 'uint8'); % 读取文件头 (header)
    
    % 文件指针移动到BitsPerSample字段
    fseek(fid, 68, 'bof'); 
    % 读取字段，该字段为2字节的无符号整数（Little-Endian 格式）
    bits_per_sample = fread(fid, 1, 'uint16'); 
    
    % 将文件指针移动到数据块 (Data Chunk) 处，包含实际的音频采样数据
    fseek(fid, 78, 'bof'); 
    % 根据BitsPerSample的值动态设置读取的数据类型
    data = fread(fid, inf, ['uint', num2str(bits_per_sample)]); 
    fclose(fid); 
end