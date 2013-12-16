function x = rootn(A, n, eps)
  x = A
  while norm(x .^ n - A) > eps
    x = 1/n * ((n-1) * x + A / x ^ (n-1))
  end
end

printf('%f', rootn(7, 3, 1e-10))
