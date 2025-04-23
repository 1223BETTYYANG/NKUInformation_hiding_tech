%DWT1
wav_name = "partofS.wav";
[wav,fs] = audioread (wav_name) ;
[ca1,cd1]=dwt(wav(:,1),'db4');
%小波基选用Daubechies-4小波db4一级小波分解，取原音频的
wav0=idwt(ca1,cd1,'db4',length(wav(:,1)));
%db4一级小波分解重构-逆dwt

figure('name','DWT一级小波分解与重构');
ax(1)=subplot(2,2,1);
plot(wav(:,1));
title('Raw wave')
grid on;
ax(2)=subplot(2,2,2);
plot(cd1);
title('Component of Detail')
grid on;
ax(3)=subplot(2,2,3);
plot(ca1);
title('Approximate Component')
grid on;
ax(4)=subplot(2,2,4);
plot(wav0);
title('Recovered wave')
grid on;

linkaxes(ax,'x');