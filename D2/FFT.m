%FFT
wav_name = "partofS.wav";
wav = audioread (wav_name) ;
plot(wav) ;
f_wav=fft(wav);
%t函数--快速离散傅里叶变换
r_wav=ifft(f_wav);%逆变换
figure('name','FFT');
subplot(3,1,1);
plot(wav);
title('Raw audio')
subplot(3,1,2);
plot(abs(fftshift(f_wav)));
ylabel('Amplitude');
title('Signal FFT Analysis Result');
grid on;
subplot(3,1,3);
plot(r_wav);
title('Restored audio')