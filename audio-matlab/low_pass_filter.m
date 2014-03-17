Fs = 44100;

t = 0:1/Fs:.7;

x = sin(2*pi*t * 440);
y = x + sin(2*pi*t * 4000); % signal with high-freqency noise

% lps using average
q = floor(Fs/2000); % 1/q * Fs cutoff frequency
y3 = filter(ones(1, q) ./ q, 1, y);

%sound(y, Fs);
sound(y3, Fs);