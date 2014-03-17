Fs = 44100;

t = 0:1/Fs:.7;

x = sin(2*pi*t * 440);
y = x + sin(2*pi*t * 4000); % signal with high-freqency noise

%sound(y, Fs);


% filter using fft
Y = fft(y);
f = linspace(1, Fs/2, length(y)/2);

% kill high frequencies
freq600 = floor(600 * length(y)/2 / (Fs/2));

Y2 = Y;
Y2(420:length(Y2)) = zeros(1, length(Y2) - 420+1);
y2 = ifft(Y2);

%sound(x, Fs);
%sound(real(y2), Fs);

q = floor(Fs/2000); % 1/q * Fs cutoff frequency
y3 = filter(ones(1, q) ./ q, 1, y);

%sound(y, Fs);
%sound(x, Fs);
sound(y3, Fs);