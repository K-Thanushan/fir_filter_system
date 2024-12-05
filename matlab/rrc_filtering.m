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
%---------------------------Impulse input vector generation-------------------------%
impulse_input = zeros(size(rrc_filter));
impulse_input(1) = 1;
impulse_input_fixed = float_to_fixed(impulse_input, word_length, fractional_length);
save_array_to_text(impulse_input_fixed, 'impulse_input.txt');
%-----------------------------------------------------------------------------------%

%-----------------------------------------------------------------------------------%
%--------------------------Impulse Output Vector generation-------------------------%
impulse_output_fixed = fixed_point_filter(rrc_filter_fixed, impulse_input_fixed, scaling_factor);
impulse_output = impulse_output_fixed/scaling_factor;
save_array_to_text(impulse_output_fixed, 'expected_impulse_response.txt');
%-----------------------------------------------------------------------------------%

%-----------------------------------------------------------------------------------%
%-------------------------I-upsampled input vector generation-----------------------%
I_input = [0.1,0.9,0.1,0.9,-0.1,-0.9,-0.1,-0.9,0.1,0.9,0.1,0.9,-0.1,-0.9,-0.1,-0.9];
%I_input = randi(7,1,100)-4;
I_upsampled_input = zeros(1,186);
for i = 1:length(I_input)
    I_upsampled_input((i-1)*1 + 1) = I_input(i);
end
I_upsampled_input_repeated = repmat(I_upsampled_input, 1, 10);
I_upsampled_input_fixed = float_to_fixed(I_upsampled_input_repeated, word_length, fractional_length);
save_array_to_text(I_upsampled_input_fixed, 'I_upsampled_input_fixed.txt');
%-----------------------------------------------------------------------------------%

%-----------------------------------------------------------------------------------%
%------------------------I-upsampled output vector generation-----------------------%
I_upsampled_output_fixed = fixed_point_filter(rrc_filter_fixed, I_upsampled_input_fixed, scaling_factor);
I_upsampled_output = I_upsampled_output_fixed/scaling_factor;
save_array_to_text(I_upsampled_output_fixed, 'I_upsampled_expected_response.txt');
x = 1:1:length(I_upsampled_output);
figure;
stem(x, I_upsampled_output,'b', 'LineWidth', 2);
% legend('float', 'fixed');
title('RRC Filter I Response');
% hold off;
%-----------------------------------------------------------------------------------%

%-----------------------------------------------------------------------------------%
%-------------------------Q-upsampled input vector generation-----------------------%
Q_input = [0.1,0.1,0.3,0.3,0.1,0.1,0.3,0.3,-0.1,-0.1,-0.3,-0.3,-0.1,-0.1,-0.3,-0.3];
Q_upsampled_input = zeros(1,186);
for i = 1:length(Q_input)
    Q_upsampled_input((i-1)*10 + 1) = Q_input(i);
end
Q_upsampled_input_repeated = repmat(Q_upsampled_input, 1, 1);
Q_upsampled_input_fixed = float_to_fixed(Q_upsampled_input_repeated, word_length, fractional_length);
save_array_to_text(Q_upsampled_input, 'Q_upsampled_input.txt');
save_array_to_text(Q_upsampled_input_fixed, 'Q_upsampled_input_fixed.txt');
%-----------------------------------------------------------------------------------%

%-----------------------------------------------------------------------------------%
%------------------------Q-upsampled output vector generation-----------------------%
Q_upsampled_output_fixed = fixed_point_filter(rrc_filter_fixed, Q_upsampled_input_fixed, scaling_factor);
Q_upsampled_output = Q_upsampled_output_fixed/scaling_factor;
save_array_to_text(Q_upsampled_output, 'Q_upsampled_expected_response.txt');
x = 1:1:length(Q_upsampled_output);
figure;
stem(x, Q_upsampled_output,'r', 'LineWidth', 2);
% legend('float', 'fixed');
title('RRC Filter Q Response');
% hold off;
%-----------------------------------------------------------------------------------%

%-----------------------------------------------------------------------------------%
%------------------Spectrum View of Pulse Shaped Output-----------------------------%
Fs = 1000;            % Sampling frequency (Hz)
T = 1/Fs;             % Sampling period (seconds)
L = length(I_upsampled_output);             % Length of signal (number of samples)
t = (0:L-1)*T;        % Time vector
% Compute the FFT
Y = fft(I_upsampled_output, L);



% Compute the two-sided spectrum and then the single-sided spectrum
P2 = abs(Y/L);          % Two-sided spectrum
P1 = P2(1:L/2+1);       % Single-sided spectrum
P1(2:end-1) = 2*P1(2:end-1);

% Compute the normalized frequency axis (0 to 1)
f_normalized = (0:L/2)/L;

% Plot the FFT
figure;
semilogy(f_normalized, P1);
%plot(f_normalized, P1)
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('Normalized Frequency (×π rad/sample)')
ylabel('log|P1(f)|')
%-----------------------------------------------------------------------------------%

%-----------------------------------------------------------------------------------%
%-------------------------Spectrum View of Q output---------------------------------%
Fs = 1000;            % Sampling frequency (Hz)
T = 1/Fs;             % Sampling period (seconds)
L2 = length(Q_upsampled_output);             % Length of signal (number of samples)
t = (0:L-1)*T;        % Time vector
% Compute the FFT
Y2 = fft(Q_upsampled_output, L);

% Compute the two-sided spectrum and then the single-sided spectrum
P2_2 = abs(Y2/L);          % Two-sided spectrum
P1_2 = P2_2(1:L/2+1);       % Single-sided spectrum
P1_2(2:end-1) = 2*P1_2(2:end-1);

% Compute the normalized frequency axis (0 to 1)
f_normalized_2 = (0:L2/2)/L2;

% Plot the FFT
figure;
semilogy(f_normalized, P1_2);
%plot(f_normalized, P1)
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('Normalized Frequency (×π rad/sample)')
ylabel('log|P1_2(f)|')
%-----------------------------------------------------------------------------------%