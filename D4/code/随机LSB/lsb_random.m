% WAV Audio Steganography using LSB or Second-LSB
% Randomly choose between LSB and second-LSB for embedding
clc;
clear;
close all;

% Load cover audio data
[header_data, cover_samples, sample_bits] = wav_read("cover.wav");

% Load payload audio data as bits
payload_file = fopen("payload.wav", "r");
payload_bits = fread(payload_file, 'ubit1');
fclose(payload_file);
cover_length = length(cover_samples);
payload_length = length(payload_bits);
fprintf('Cover audio length: %d samples\n', cover_length);
fprintf('Payload audio length: %d samples\n', payload_length);
assert(payload_length <= cover_length, "Payload length must not exceed cover length!");

% Generate random bit choices for embedding
random_choices = randi(2, payload_length, 1);

% Embed payload into cover audio
embedded_audio = cover_samples;
for idx = 1:payload_length
    embedded_audio(idx) = bitset(cover_samples(idx), random_choices(idx), payload_bits(idx));
end

% Save embedded audio as WAV file
output_file = fopen("embedded_audio.wav", "w");
fwrite(output_file, header_data, 'uint8');
fwrite(output_file, embedded_audio, ['uint', num2str(sample_bits)]);
fclose(output_file);

% Extract payload from embedded audio
[header_data, embedded_audio, sample_bits] = wav_read("embedded_audio.wav");
extracted_bits = zeros(size(embedded_audio));
for idx = 1:payload_length
    extracted_bits(idx) = bitget(embedded_audio(idx), random_choices(idx));
end

% Determine the true size of the extracted info
info_length_bits = extracted_bits(33:64);
info_length = uint32(0);
for idx = 1:32
    info_length = bitset(info_length, idx, info_length_bits(idx));
end
info_length = info_length + 8; % Include `ChunkID` and `ChunkSize` (8 bytes total)
info_length = info_length * 8; % Convert to bits

% Save extracted info as WAV file
info_file = fopen("extracted_info.wav", "w");
fwrite(info_file, extracted_bits(1:info_length), 'ubit1');
fclose(info_file);

% Display results
[cover_audio_y, Fs_cover] = audioread("cover.wav");
cover_audio_x = (0:length(cover_audio_y)-1) / Fs_cover;
[payload_audio_y, Fs_payload] = audioread("payload.wav");
payload_audio_x = (0:length(payload_audio_y)-1) / Fs_payload;
[embedded_audio_y, Fs_embedded] = audioread("embedded_audio.wav");
embedded_audio_x = (0:length(embedded_audio_y)-1) / Fs_embedded;
[info_audio_y, Fs_info] = audioread("extracted_info.wav");
info_audio_x = (0:length(info_audio_y)-1) / Fs_info;

figure(1);
subplot(2, 2, 1);
plot(cover_audio_x, cover_audio_y);
xlabel('Time (s)'); ylabel('Amplitude');
title("Cover Audio");

subplot(2, 2, 2);
plot(payload_audio_x, payload_audio_y);
xlabel('Time (s)'); ylabel('Amplitude');
title("Payload Audio");

subplot(2, 2, 3);
plot(embedded_audio_x, embedded_audio_y);
xlabel('Time (s)'); ylabel('Amplitude');
title("Embedded Audio");

subplot(2, 2, 4);
plot(info_audio_x, info_audio_y);
xlabel('Time (s)'); ylabel('Amplitude');
title("Extracted Audio");

% Detailed display of results
figure(2);
axis_limits = [4.5, 5, -1, 1];

subplot(2, 2, 1);
plot(cover_audio_x, cover_audio_y);
axis(axis_limits);
xlabel('Time (s)'); ylabel('Amplitude');
title("Cover Audio");

subplot(2, 2, 2);
plot(payload_audio_x, payload_audio_y);
axis(axis_limits);
xlabel('Time (s)'); ylabel('Amplitude');
title("Payload Audio");

subplot(2, 2, 3);
plot(embedded_audio_x, embedded_audio_y);
axis(axis_limits);
xlabel('Time (s)'); ylabel('Amplitude');
title("Embedded Audio");

subplot(2, 2, 4);
plot(info_audio_x, info_audio_y);
axis(axis_limits);
xlabel('Time (s)'); ylabel('Amplitude');
title("Extracted Audio");