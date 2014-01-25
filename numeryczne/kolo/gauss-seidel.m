% check whether matrix is strictly diagonally dominant
function res = isStrictDiagonallyDominant(A)
  res = all( 2*abs(diag(A)) > sum(abs(A),2) )
endfunction

% check whether matrix is positive definite
function res = isPositiveDefinite(A)
  res = all(eig(A) > 0)
endfunction

% check whether matrix is symmetric
function res = isSymmetric(A)
  res = all(all(A == A'))
endfunction

% check whether matrix is symmetric and positive definite
function res = isSymmetricPositiveDefinite(A)
  res = isPositiveDefinite(A) && isSymmetric(A)
endfunction

% gauss seidel method
function  x = gaussSeidel(A, b, eps)
  if !isStrictDiagonallyDominant(A) && !isSymmetricPositiveDefinite(A)
    printf('%s\n', 'Method can be non-convergent!')
  endif

  L = tril(A)
  Us = triu(A,1)
  invL = inv(L)

  x = b

  while norm(A*x - b) > eps
    x = invL * (b - Us * x)
  end
endfunction

% Just use previously implemented Gauss-Seidel method
% Since the results are bigger than 1 the relative error
% is smaller than 10^-3
% Also please notice that the columns of the original
% matrix are permuted so that the diagonal is strictly
% dominant
A = [
    10  0.2  1 -1;
  -0.2    4 -1  2;
     0   -1  5 -2;
    -1    0 -2  4
]
b = [-10; 30; 0; 5]

x = gaussSeidel(A, b, 1e-10)
