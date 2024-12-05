import numpy as np
import matplotlib.pyplot as plt

def sinc_filter(fc, num_taps, fs):
    if num_taps%2==1:
        t = np.arange(-(num_taps // 2), (num_taps // 2) + 1)
    else:
        t = np.arange(-(num_taps // 2), (num_taps // 2))

    h = np.sinc(2 * fc * t / fs)

    window = np.hamming(num_taps)
    h = h * window

    h = h / np.sum(h)

    return h

def plot_response(h):
    # Frequency response
    w, H = np.fft.fftfreq(len(h)), np.fft.fft(h)
    w = np.fft.fftshift(w)
    H = np.fft.fftshift(H)
    
    # Plot the impulse response
    plt.figure(figsize=(12, 6))
    plt.subplot(2, 1, 1)
    plt.stem(h)
    plt.title("Impulse Response")
    plt.xlabel("Sample")
    plt.ylabel("Amplitude")
    
    # Plot the magnitude response
    plt.subplot(2, 1, 2)
    plt.plot(w, 20 * np.log10(np.abs(H)))
    plt.title("Frequency Response")
    plt.xlabel("Normalized Frequency (×π rad/sample)")
    plt.ylabel("Magnitude (dB)")
    plt.grid()
    plt.show()

if __name__ == "__main__":

    fc = 0.15
    order = 50
    num_taps = order + 1
    fs = 1

    coefficients = sinc_filter(fc, num_taps, fs)
    np.set_printoptions(precision=18, suppress=True)
    print("Filter Coefficients:")
    print(coefficients)
    np.savetxt("C:/Work/fir_filter_system/tb/filter_coefficients.txt", coefficients, fmt='%.20f')
    plot_response(coefficients)