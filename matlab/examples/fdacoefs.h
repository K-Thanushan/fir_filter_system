/*
 * Filter Coefficients (C Source) generated by the Filter Design and Analysis Tool
 * Generated by MATLAB(R) 24.1 and Signal Processing Toolbox 24.1.
 * Generated on: 22-Aug-2024 17:39:01
 */

/*
 * Discrete-Time FIR Filter (real)
 * -------------------------------
 * Filter Structure  : Direct-Form FIR
 * Filter Length     : 51
 * Stable            : Yes
 * Linear Phase      : Yes (Type 1)
 */

/* General type conversion for MATLAB generated C-code  */
#include "tmwtypes.h"
/* 
 * Expected path to tmwtypes.h 
 * C:\MATLAB\R2024a\extern\include\tmwtypes.h 
 */
/*
 * Warning - Filter coefficients were truncated to fit specified data type.  
 *   The resulting response may not match generated theoretical response.
 *   Use the Filter Design & Analysis Tool to design accurate
 *   int16 filter coefficients.
 */
const int BL = 51;
const int16_T B[51] = {
        0,      3,      4,      1,     -5,    -11,     -8,      8,     29,
       34,      8,    -40,    -65,    -20,     94,    190,    129,   -175,
     -630,   -925,   -634,    541,   2541,   4862,   6732,   7449,   6732,
     4862,   2541,    541,   -634,   -925,   -630,   -175,    129,    190,
       94,    -20,    -65,    -40,      8,     34,     29,      8,     -8,
      -11,     -5,      1,      4,      3,      0
};
