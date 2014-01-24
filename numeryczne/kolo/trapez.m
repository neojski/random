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

  if err > e # if error is too big: bisect
    v = integrate(a, a + (b - a) / 2, e/2) + integrate(a + (b - a) / 2, b, e/2)
  end
end

integrate(1, 2, 0.01)
