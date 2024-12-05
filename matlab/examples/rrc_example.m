rolloff_factor = 0.35;
span = 5;
sps = 10;
% filter = rcosdesign(rolloff_factor, span, sps,"sqrt");
% stem(filter);

b = rcosdesign(rolloff_factor, span, sps, "sqrt");
WL = 16;
FL = 15; %floor(log2((2^(B-1)-1)/max(b))); %Round towards zero to avoid overflow
b_fixed = float_to_fixed(b, WL, FL);
% bsc = b*2^FL;
h = dfilt.dffir(b);
% h.Arithmetic = 'fixed';
all(h.Numerator == round(h.Numerator));
fvtool(h, 'Color', 'white');
h_fixed = dfilt.dffir(b_fixed);
h_fixed_down = dfilt.dffir(b_fixed);%/(2^FL));
fvtool(h, h_fixed_down);
legend('Filter 1 (float)', 'Filter 2 (scaled_down)');
info(h);
x = 1:1:51;
figure;
stem(x, b, 'r', 'LineWidth', 2);
% hold on;
b_c = b_fixed/(2^FL);
stem(x, b_c,'b', 'LineWidth', 2);
% legend('float', 'fixed');
title('RRC Filter Response');
% hold off;
