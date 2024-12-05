biquad = design(fdesign.lowpass('Fp,Fst,Ap,Ast',0.4,0.45,0.5,80),'ellip',FilterStructure='df1sos', SystemObject=true, UseLegacyBiquadFilter=true);
fvt = fvtool(biquad, Legend='on');
fvt.SosviewSettings.View = 'Cumulative';
sosMatrix = biquad.SOSMatrix;
sclValues = biquad.ScaleValues;
fvt_comp = fvtool(sosMatrix,float_to_fixed(sosMatrix,16,15));
legend(fvt_comp,'Floating-point (double) SOS','Fixed-point (16-bit) SOS');
b = repmat(sclValues(1:(end-1)),1,3) .* sosMatrix(:,(1:3));
a = sosMatrix(:,(5:6));
num = b'; % matrix of scaled numerator sections
den = a'; % matrix of denominator sections
close(fvt);      % clean up
close(fvt_comp); % clean up