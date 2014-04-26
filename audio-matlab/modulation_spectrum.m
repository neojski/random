Fs = 10000;
t = 0:(1/Fs):1;
% message with rooftop spectrum
m = 3 * sin(2*pi*t * 0) + 2.5 * sin(2*pi*t*12.5) + 2 * sin(2*pi*t * 25) + 1.5 * sin(2*pi*t* 37) + sin(2*pi*t * 50); % bandwidth = 
f = 1500;
x = (1+(1/max(m)) .* m) .* cos(2*pi*t * f); % modulation

X = fft([x zeros(1, 1000)]); % padding so that fft is more detailed

a = 0:(length(X)-1);
a = a / length(a) * Fs;
plot(a, abs(X));