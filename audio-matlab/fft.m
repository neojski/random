Fs = 44100; % sampling frequency

t = 0:1/Fs:.7; % just .7 seconds
y = sin(2*pi*t * 440) + sin(2*pi*t * 880) + randn(1, length(t)); % two sinuses + noise

Y = fft(y);
% sampling frequency is Fs so the signal is bandlimited Fs/2
% frequencies returned by fft are therefore:
f = Fs/2 * linspace(0, 1, length(Y)/2);

PY = abs(Y).^2; % we may be also interested in the power of each frequency

plot(f, Y(1:length(f)));