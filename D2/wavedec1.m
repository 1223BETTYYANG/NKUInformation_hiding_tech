%WAVEDEC1
wav_name = "partofS.wav";
[wav,fs] = audioread (wav_name) ;
[ca1,cd1]=wavedec(wav(:,1),1 ,'db4'); % 小波基选用 Daubechies-4 小波
wav0=waverec(ca1,cd1,'db4') ;         % 逆 wavedec

subplot (2 ,2 ,1) ; plot (wav( : , 1)) ; 
subplot (2 ,2 ,2) ; plot ( cd1 ) ;    %细节分量
subplot (2 ,2 ,3) ; plot ( ca1 ) ;    %近似分量
subplot (2 ,2 ,4) ; plot ( wav0 ) ; 
axes_handle = get ( gcf,'children') ;
axes ( axes_handle (4) ) ; title('Raw wave') ;
axes ( axes_handle (3) ) ; title('Detail Component') ;
axes ( axes_handle (2) ) ; title('Approximate Component') ;
axes ( axes_handle (1) ) ; title('Recovered wave') ;