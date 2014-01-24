function vf = f(x)
  vf = exp(x^2) * sin(x)
end

# second derivative bound
function vg = g(x)
  vg = exp(x^2) * (4 * x^2 + 1 + 4 * x)
end

global p = 100

function v = integrate(a, b, e)
  v = (f(a) + f(b)) / 2 * (b - a)
  err = g(b) * (b - a) ^ 3 / 12

  if err > e # if error is too big: bisect
    v = integrate(a, a + (b - a) / 2, e/2) + integrate(a + (b - a) / 2, b, e/2)
  else
    global p
    p++
  end
end

v1 = integrate(1, 2, 0.01)
printf "\n%d\n", p

n = p
v = 0
a = 1
b = 2
for i = 0:n-1
  x1 = a + i/n
  x2 = a + (i+1)/n
  v += (f(x1) + f(x2)) / 2 * (b - a) / n
end

printf "\n%d %d %d\n", p, v1, v
