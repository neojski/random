function vf = f(x)
  vf = exp(x^2) * sin(x)
end

function v = integrate(a, b, e)
  v = (f(a) + f(b)) / 2 * (b - a)
  # for increasing functions error is no bigger than half of
  # (a, f(a)), (b, f(b)) rectangle
  err = (f(b) - f(a)) / 2 * (b - a)

  if err > e # if error estimate is too big: bisect
    v = integrate(a, a + (b - a) / 2, e/2) + integrate(a + (b - a) / 2, b, e/2)
  end
end

# Let c ~ int f. f is increasing so relative error:
# (int - c) / int <= (int - c) / f(a)
# We want it <= 0.01, so calculate with absolute error
# <= 0.01 * f(a)

a = 1
b = 2
e = 0.01
v1 = integrate(a, b, e * f(a))
