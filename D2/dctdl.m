%DCT
wav_name = "partofS.wav";
[wav,fs] = audioread (wav_name) ;
da=dct(wav); % dct
wav0=idct(da); % 逆 dct

figure('name','离散余弦变换');
subplot(3,1,1);plot(wav);title('Raw wave')
subplot(3,1,2);plot(da);title('DCT')
subplot(3,1,3);plot(wav0);title('Restored wave')