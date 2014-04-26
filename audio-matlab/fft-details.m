N = 10;
K = 40; % increase this value to see more details of the spectra

f0 = ones(1,N);
f = [f0 zeros(1,K-N)];

y = fft(f);

plot((1:K) / K, y)