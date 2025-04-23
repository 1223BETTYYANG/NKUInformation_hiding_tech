%WAVEDEC3
wav_name = "partofS.wav";
[wav,fs] = audioread (wav_name) ;
[c,l]=wavedec(wav(:,2),3,'db4');%db4小波三级分解

ca3=appcoef(c,l,'db4',3);       %三级分解近似分量(低)
cd3=detcoef(c,l,3);             %三级分解细节分量(高)
cd2=detcoef(c,l,2);             %二级细节分量(高)
cd1=detcoef(c,l,1);             %一级细节分量(高)
a0=waverec(c,l,'db4');          %三级重构

figure('name','三级小波分解与重构');
ax(1)=subplot(6,1,1);plot(wav(:,2));title('Raw wave') ;
grid on;
ax(2)=subplot(6,1,2);plot(cd1);title('L1 Detail Component') ;
grid on;
ax(3)=subplot(6,1,3);plot(cd2);title('L2 Detail Component') ;
grid on;
ax(4)=subplot(6,1,4);plot(cd3);title('L3 Detail Component') ;
grid on;
ax(5)=subplot(6,1,5);plot(ca3);title('L3 Approximate Component') ;
grid on;
ax(6)=subplot(6,1,6);plot(a0);title('Recovered wave') ;
grid on;
linkaxes(ax,'x');