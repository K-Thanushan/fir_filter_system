import numpy as np
import matplotlib.pyplot as plt

def plot_impulse_response(array1, array2, num_taps):
    #if num_taps%2==1:
    t = np.linspace(0, 1, num_taps)
    plt.plot(t, array1, label="Expected response", color="red", linestyle="-.")
    plt.plot(t, array2, label="Actual response", color="blue", linestyle="--")

    plt.title("Actual and Expected Impulse Responses")
    plt.xlabel('t')
    plt.ylabel('y')
    plt.legend()
    plt.savefig("C:/Work/fir_filter_system/tb/impulse_responses_axis.png", dpi=300)
    plt.show()

if __name__ == "__main__":
    order = 50
    num_taps = order + 1
    
    expected_array = np.loadtxt("C:/Work/fir_filter_system/tb/filter_coefficients.txt")
    actual_array = np.loadtxt("C:/Work/fir_filter_system/tb/cocotb_impulse_response.txt")
    plot_impulse_response(expected_array,actual_array,num_taps)
