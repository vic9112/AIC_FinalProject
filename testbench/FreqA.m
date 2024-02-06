% using FFT 
%any parameter using two side spectrum to calculate
function [ENOB ,SNDR, SFDR]=FreqA(Daq,fs)
N=size(Daq,1); 
if N==1
    N=size(Daq,2); 
end
y=(abs(fft(Daq))/N);    %power spectrum
y(1)=0;                 %cancel DC value
figure;
x=(0:((N)/2)).*(fs/N);
min=-150;
y=y/max(y);
ydb=(mag2db(y(1:N/2+1)));
for k=1:1:length(ydb)
    if ydb(k,1)<min
        y(k,1)=10^(min/20);
    end
end
%plot(x,mag2db(y(1:N/2+1)));
ydb=(mag2db(y(1:N/2+1)));
ydb=ydb-max(ydb);
plot(x,ydb);
[Signal, index]=max(y);
SignalPower=Signal^2*2;     %mulitply 2 because two side convert to one sinde
fin=x(index);
% =====================%TNoisePower=Noise power + Distortion power;
TNoise=y(1:N/2+1);
TNoise(index)=0;
TNoisePower=sum(TNoise.^2)*2;
% ===================
[sfdr, index]=max(TNoise);


SFDR=mag2db(Signal/sfdr);

SNDR=10*log10(SignalPower/TNoisePower);
ENOB=(SNDR-1.76)/6.02;

text(max(x)-max(x)/2,-30,sprintf('fs=%d MHz\nSNDR=%2.3f dB\nSFDR=%2.3f dB \nENOB=%2.3f bits',fs/1e6,SNDR,SFDR,ENOB),'FontSize',12);
ylabel('Power Density (dBFS/bin)');
xlabel('Frequency (Hz)');
end