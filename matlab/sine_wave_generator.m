function sine_wave = sine_wave_generator(desired_frequency, sampling_rate,n_cycles)
    % Function to generate sine waves when the desired normalized frequency
    % is given 
    % Inputs:
    %   desired_frequency - Required frequency of the sine wave in the normalized frequency domain
    %   sampling_rate     - sampling frequency to generate the signal.
    %   n_cycles          - Number of cycles of the sine wave.
    %
    % Output:
    %   sine_wave - The sine wave generated for the desired frequency
    
    %sampling rate
    fs = sampling_rate; %1000;
    t = 0:1/fs:n_cycles;
    sine_wave = sin(2*pi*desired_frequency*fs*t);
end