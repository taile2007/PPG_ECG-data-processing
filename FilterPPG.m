% ve dang cua tin hieu
fs=1000;
Lfft=1024;
ppg=load('ppg3.txt');
plot(ppg);
% ve fft cua tin hieu
subplot(211)
plot(linspace(0,fs,Lfft),abs(fft(ppg,Lfft)));
xlabel('Frequency (Hz)');
ylabel('Amplitude');
title('Before filter');
N=80;
h_ppg=fir1(N,0.2*2/fs,'high');
ppg_filterhighpass=conv(ppg,h_ppg,'same');
h1_ppg=fir1(N,20*2/fs,'low');
ppg_filter=conv(ppg_filterhighpass,h1_ppg,'same');
subplot(212)
plot(linspace(0,fs,Lfft),abs(fft(ppg_filter,Lfft)));
% xlabel('Frequency (Hz)');
% ylabel('Amplitude');
% title('After filter');
% figure
% plot(ppg_filter);

%===================R_detection on PPG===================%
ppg_signal=ppg_filter;
slp=slope(ppg_signal,12);% xet do doc cua tin hieu tham so dau vao: tin hieu va buoc nhay cua doc

high=high_detection(slp,200); % xac dinh diem dinh cua moi doc

min_high=10000;
for i=1:length(high)-3;
    high_point=slp(high(i));
    for j=i:i+3
        if slp(high(j))>high_point
            high_point=slp(high(j));
        end
    end
    if(high_point<min_high)
        min_high=high_point;
    end

end

threshold1=2*min_high;
noise_peak=high(slp(high)>threshold1);
high(slp(high)>threshold1)=[];

threshold2=0.76*(max(slp(high))+min(slp(high)))/2;
high(slp(high)<threshold2)=[];

peak=zeros(length(high),1);
n=75;
for i=1:length(high)
    max_point=ppg_signal(high(i));
    max_index=0;
    for j=-n:n
        if ppg_signal(high(i)+j)> max_point
            max_point=ppg_signal(high(i)+j);
            max_index=high(i)+j;
        end
    end
    peak(i)= max_index;
end
peak(peak==0)=[];

slp1=zeros(length(ppg_signal),1);
n1=30;
for i=1+n1:length(ppg_signal)
    if ppg_signal(i)> ppg_signal(i-n1)
        slp1(i)=ppg_signal(i)-ppg_signal(i-n1);
    else
        slp1(i)=0;
    end
end

slp1=slp1.^2;

threshold3=0.4*(min(slp1(peak))+ max(slp1(peak)))/2;
peak(slp1(peak)<threshold3)=[];
slp1(slp1<threshold3)=0;

systole_peak=peak;

figure;
plot(ppg_signal);hold on;
plot(systole_peak,ppg_signal(systole_peak),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6);
xlabel('Sample');
title('Systole points-PPG signal');

%===================Heart rate estimation===================%

HR=zeros(length(systole_peak),1);
for i=2:length(systole_peak)              % HR(1)=0
    j=find(noise_peak < systole_peak(i),1,'last');
        if noise_peak(j)>systole_peak(i-1)
            HR(i)=0;
        else
            HR(i)=60*fs/(systole_peak(i)-systole_peak(i-1));
        end
end

figure;
stem(HR,'ro','MarkerEdgeColor','b','MarkerFaceColor','b','MarkerSize',6);
title('Heart Rate');


