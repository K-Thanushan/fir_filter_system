% Parameters for the signal
% Fs = 1000;            % Sampling frequency (Hz)
% T = 1/Fs;             % Sampling period (seconds)
% L = 1500;             % Length of signal (number of samples)
% t = (0:L-1)*T;        % Time vector
% 
% % Generate a signal composed of two sinusoids
% f1 = 50;              % Frequency of first sinusoid (Hz)
% f2 = 120;             % Frequency of second sinusoid (Hz)
% signal = 0.7*sin(2*pi*f1*t) + sin(2*pi*f2*t);
% 
% % Add some noise
% %signal = signal + 2*randn(size(t));
% 
% % Compute the FFT
% Y = fft(signal);
% 
% % Compute the two-sided spectrum and then the single-sided spectrum
% P2 = abs(Y/L);          % Two-sided spectrum
% P1 = P2(1:L/2+1);       % Single-sided spectrum
% P1(2:end-1) = 2*P1(2:end-1);
% 
% % Compute the normalized frequency axis (0 to 1)
% f_normalized = (0:(L/2))/L;
% 
% % Plot the FFT
% figure;
% plot(f_normalized, P1)
% title('Single-Sided Amplitude Spectrum of X(t)')
% xlabel('Normalized Frequency (×π rad/sample)')
% ylabel('|P1(f)|')



Fs = 40000;
t = 0:1/Fs:(2e3*1/Fs)-1/Fs;
y = cos(2*pi*5000*t)+randn(size(t));
T = 1/Fs;
L = 2000;
NFFT = 2^nextpow2(L);
Y = abs(fft(y,NFFT))/L;
f = Fs/2*linspace(0,1,NFFT/2+1);
plot(f,2*abs(Y(1:NFFT/2+1)))