function vf = f(x)
  vf = exp(x^2) * sin(x)
end

# second derivative bound
function vg = g(x)
  vg = exp(x^2) * (4 * x^2 + 1 + 4 * x)
end

function v = integrate(a, b, e)
  v = (f(a) + f(b)) / 2 * (b - a)
  err = g(b) * (b - a) ^ 3 / 12

  if err > e # if error estimate is too big: bisect
    v = integrate(a, a + (b - a) / 2, e/2) + integrate(a + (b - a) / 2, b, e/2)
  end
end

function s = simpson(a, b)
  s = (b-a) / 6 * (f(a) + 4 * f((a+b)/2) + f(b))
end
function v = do_integrate_simpson(a, b, e, T)
  c = (a+b) / 2
  l = simpson(a, c)
  r = simpson(c, b)
  if (abs(l + r - T) <= 15 * e)
    v = l + r + (l + r - T) / 15
  else
    v = do_integrate_simpson(a, c, e/2, l) + do_integrate_simpson(c, b, e/2, r)
  end
end
function v = integrate_simpson(a, b, e, T)
  v = do_integrate_simpson(a, b, e, simpson(a, b))
end

function v = integrate_simple(a, b, e)
  n = 100
  v = 0
  for i = 0:n-1
    x1 = a + i/n
    x2 = a + (i+1)/n
    v += (f(x1) + f(x2)) / 2 * (b - a) / n
  end
end

v1 = integrate(1, 2, 0.01)
v2 = integrate_simpson(1, 2, 0.01)
v3 = integrate_simple(1, 2, 0.01)

printf "\n%d %d %d %d\n", v1, v2, v3
