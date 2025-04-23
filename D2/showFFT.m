%show fft
wav_name = "partofS.wav";
wav = audioread (wav_name) ;
plot(wav) ;
f_wav=fft(wav);
%t函数--快速离散傅里叶变换
figure('name','FFT');
plot(abs(fftshift(f_wav)));
ylabel('Amplitude');
title('Signal FFT Analysis Result');
grid on;

