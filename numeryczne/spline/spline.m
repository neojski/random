function v = f(x)
  v = exp(-2.*x) .* sin(10*pi.*x)
end

x = linspace(0,10, 10000)
t = 0:0.5:10

hold on
plot(x, f(x))
plot(x, interp1(t, f(t), x, 'linear'), 'r')
plot(x, interp1(t, f(t), x, 'cubic'), 'g')

pause
