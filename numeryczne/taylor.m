function f = taylor(x,N)
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
  pause
endfunction

taylor(linspace(0,2), 5)
