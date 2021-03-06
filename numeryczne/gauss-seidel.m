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

  x = zeros(size(b), 1)

  while norm(A*x - b) > eps
    x = invL * (b - Us * x)
  end
endfunction


% example usage
A = [2 0 1; 0 1 0; 0 0 1]
b = [1; 2; 3]

x = gaussSeidel(A, b, 1e-10)
