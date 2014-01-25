# We change the original function to f
# so that we can calculate the fixed point of it
function v = f(x)
  v = (4 * nthroot(x, 4) - 0.00001) ^ 3
end

# It's easy to check that second derivative of f
# is < 0 for x > 1e7. So the first derivative is
# decreasing and so let's take its value at 1e7:
# <= 0.9. Let q = 0.9. So f is Lipschitz with 0.9 constant
# We know the following inequality (Banach fixed
# point theorem:
# d(x*, x_n) <= q^n / (1 - q) d(x_1, x_0) =
# 0.9^n / 0.1 d(x_1, x_0)
# So this is the possible error value. We want the relative
# error here but since the root is bigger than 1e7 the
# relative error is much smaller than the absolute one

x = 2e7 # initial root guess
err = 1 / 0.1 * abs(f(x) - x)

j = 100
while err > 0.001
  y = f(x)
  x = y

  err *= 0.9
end
