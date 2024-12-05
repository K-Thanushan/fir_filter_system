% Parameters
fs = 1000;              % Sampling frequency
nCyl = 5;              % To generate five cycles of sine wave

% Normalized frequency
f_norm = 0.1; %f / fs;       % frequency of sine wave (Normalized frequency)

t = 0:1/fs:nCyl; % Time base
x_01 = sine_wave_generator(f_norm,fs, nCyl);% sin(2 * pi * f_norm * fs * t); % Sine wave with normalized frequency
x_02 = sine_wave_generator(0.4,fs, nCyl);
x = x_01 + x_02;
figure;
plot(t, x);
title(['Sine Wave with Normalized Frequency = ', num2str(f_norm)]);
xlabel('Time (s)');
ylabel('Amplitude');
ylim([-5, 5]);

%-----Raw values against normalized spectrum-----%
NFFT=1024; %NFFT-point DFT      
X=fft(x,NFFT); %compute DFT using FFT        
nVals=(0:NFFT-1)/NFFT; %Normalized DFT Sample points         
figure;
plot(nVals,abs(X));      
title('Double Sided FFT - without FFTShift');        
xlabel('Normalized Frequency')       
ylabel('DFT Values');
xlim([-0.5,1.5]);

%--ABsolute frequency in the x axis -----%
NFFT=1024;      
X=fftshift(fft(x,NFFT));         
fVals=(-NFFT/2:NFFT/2-1)/NFFT;        
figure;
plot(fVals,abs(X),'b');      
title('Double Sided FFT - with FFTShift');       
xlabel('Frequency (Hz)')         
ylabel('|DFT Values|');
xlim([-1,1.5]);