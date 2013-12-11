function taylor(x,N)
  f = zeros(size(x))
  name = ''

  hold on
  for n = 0:N
    f += (1/prod(1:n)) * x .^ n
    name = strcat(name, '+1/', int2str(n), '! x^', int2str(n))
    h = plot(x, f, strcat(';', name, ';'))

    set(h, 'Color', [n/(N+1), 1-n/(N+1), 0])
  endfor

  plot(x, exp(x), 'r-;exp(x);')
  hold off
end

function poly(x,N)
  hold on
  p = polyfit(x, exp(x), N)

  plot(x, polyval(p, x), strcat('b-;poly(', int2str(N), ');'))
end

x = linspace(0,2)
taylor(x, 5)
poly(x, 5)
pause
