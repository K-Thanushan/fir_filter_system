%-----------------------------------------------------------------------------------%
%-----------------------------------RRC Filter--------------------------------------%
rolloff_factor = 0.35;
filter_span    = 5; %in symbols
samples_per_symbol = 10;
rrc_filter = rcosdesign(rolloff_factor, filter_span, samples_per_symbol, "sqrt");
save_array_to_text(rrc_filter, "filter_coefficients.txt");
%-----------------------------------------------------------------------------------%

%-----------------------------------------------------------------------------------%
%-----------------------------Fixed Arithmetic Parameters---------------------------%
word_length = 16;
fractional_length = 15;
scaling_factor = 2^fractional_length;
%-----------------------------------------------------------------------------------%

%-----------------------------------------------------------------------------------%
%--------------------------Float to fixed conversion - filter-----------------------%
rrc_filter_fixed = float_to_fixed(rrc_filter, word_length, fractional_length);
%-----------------------------------------------------------------------------------%

%-----------------------------------------------------------------------------------%
%-------------------------------Filter Visualization--------------------------------%
rrc_float = dfilt.dffir(rrc_filter);
rrc_fixed = dfilt.dffir(rrc_filter_fixed);
rrc_fixed_scaleddown = dfilt.dffir(rrc_filter_fixed/scaling_factor);
fvtool(rrc_float, rrc_fixed, rrc_fixed_scaleddown);
%legend('Filter 1 (float)', 'Filter 2 (fixed)', 'Filter 3 (scaled_down)');
%-----------------------------------------------------------------------------------%


%-----------------------------------------------------------------------------------%
%---------------------------Impulse input vector generation-------------------------%
impulse_input = zeros(size(rrc_filter));
impulse_input(1) = 1;
impulse_input_fixed = float_to_fixed(impulse_input, word_length, fractional_length);
save_array_to_text(impulse_input, 'impulse_input.txt');
%-----------------------------------------------------------------------------------%

%-----------------------------------------------------------------------------------%
%--------------------------Impulse Output Vector generation-------------------------%
impulse_output_fixed = fixed_point_filter(rrc_filter_fixed, impulse_input_fixed, scaling_factor);
impulse_output = impulse_output_fixed/scaling_factor;
save_array_to_text(impulse_output, 'expected_impulse_response.txt');
%-----------------------------------------------------------------------------------%

%-----------------------------------------------------------------------------------%
%-------------------------------Sine Wave Generation--------------------------------%
fs = 1000;
f_1 = 0.1;
f_2 = 0.4;
n_cycles = 3;
t = 0:1/fs:n_cycles; % Time base
sine_1 = sine_wave_generator(f_1, fs, n_cycles);
sine_2 = sine_wave_generator(f_2, fs, n_cycles);
sine_3 = zeros(1, length(sine_1));
sine_3 = awgn(sine_3, -5);
signal = min(max(sine_1, -0.5), 0.5); % + sine_2;
save_array_to_text(signal,'signals.txt');

figure;
plot(t, signal);
title(['Sine Wave with Normalized Frequency = ', num2str(f_1 + f_2)]);
xlabel('Time (s)');
ylabel('Amplitude');
ylim([-5, 5]);

%-----Raw values against normalized spectrum-----%
NFFT=1024; %NFFT-point DFT      
X=fft(signal,NFFT); %compute DFT using FFT        
nVals=(0:NFFT-1)/NFFT; %Normalized DFT Sample points         
figure;
plot(nVals,abs(X));      
title('Sine Wave - Double Sided FFT - without FFTShift');        
xlabel('Normalized Frequency')       
ylabel('DFT Values');
xlim([-0.5,1.5]);

%--ABsolute frequency in the x axis -----%
NFFT=1024;      
X=fftshift(fft(signal,NFFT));         
fVals=(-NFFT/2:NFFT/2-1)/NFFT;        
figure;
plot(fVals,abs(X),'b');      
title('Sine Wave - Double Sided FFT - with FFTShift');       
xlabel('Frequency (Hz)')         
ylabel('|DFT Values|');
xlim([-1,1.5]);
signal_fixed = float_to_fixed(signal, word_length, fractional_length);
save_array_to_text(signal, 'signal_float.txt');
save_array_to_text(signal_fixed, 'signal_fixed.txt');
%-----------------------------------------------------------------------------------%

%-----------------------------------------------------------------------------------%
%----------------------------Float_Filtering----------------------------------------%
float_output = floating_point_filter(rrc_filter, signal);
save_array_to_text(float_output, "float_output.txt");
float_fixed = float_to_fixed(float_output, word_length, fractional_length);
%-----Raw values against normalized spectrum-----%
NFFT=1024; %NFFT-point DFT      
float_spectrum=fft(float_output,NFFT); %compute DFT using FFT        
nVals=(0:NFFT-1)/NFFT; %Normalized DFT Sample points         
figure;
plot(nVals,abs(float_spectrum));      
title('Floating Point Output - Double Sided FFT - without FFTShift');        
xlabel('Normalized Frequency')       
ylabel('DFT Values');
xlim([-0.5,1.5]);

%--ABsolute frequency in the x axis -----%
NFFT=1024;      
float_spectrum=fftshift(fft(float_output,NFFT));         
fVals=(-NFFT/2:NFFT/2-1)/NFFT;        
figure;
plot(fVals,abs(float_spectrum),'b');      
title('Floating Point Output - Double Sided FFT - with FFTShift');       
xlabel('Frequency (Hz)')         
ylabel('|DFT Values|');
xlim([-1,1.5]);
%-----------------------------------------------------------------------------------%

%-----------------------------------------------------------------------------------%
%----------------------------Fixed_Filtering----------------------------------------%
fixed_output = fixed_point_filter(rrc_filter_fixed, signal_fixed, scaling_factor);
%-----Raw values against normalized spectrum-----%
NFFT=1024; %NFFT-point DFT      
fixed_spectrum=fft(fixed_output,NFFT); %compute DFT using FFT        
nVals=(0:NFFT-1)/NFFT; %Normalized DFT Sample points         
figure;
plot(nVals,abs(fixed_spectrum));      
title('Fixed Point Output - Double Sided FFT - without FFTShift');        
xlabel('Normalized Frequency')       
ylabel('DFT Values');
xlim([-0.5,1.5]);

%--ABsolute frequency in the x axis -----%
NFFT=1024;      
fixed_spectrum=fftshift(fft(fixed_output,NFFT));         
fVals=(-NFFT/2:NFFT/2-1)/NFFT;        
figure;
plot(fVals,abs(fixed_spectrum),'b');      
title('Fixed Point Output - Double Sided FFT - with FFTShift');       
xlabel('Frequency (Hz)')         
ylabel('|DFT Values|');
xlim([-1,1.5]);

figure;
plot(fVals,abs(fixed_spectrum)/scaling_factor,'b');      
title('Fixed Point Output - Double Sided FFT - with FFTShift - scaled down');       
xlabel('Frequency (Hz)')         
ylabel('|DFT Values|');
xlim([-1,1.5]);
%-----------------------------------------------------------------------------------%