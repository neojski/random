% check whether matrix is strictly diagonally dominant
function res = isStrictDiagonallyDominant(A)
  res = all( 2*abs(diag(A)) > sum(abs(A),2) )
endfunction

function r = spectralRadius(A)
  r = max(abs(eig(A)))
endfunction

function x = jacobi(A, b, eps)
  D = diag(diag(A))
  invD = inv(D)
  R = A - D

  if spectralRadius(invD * R) >= 1 && !isStrictDiagonallyDominant(A)
    printf('%s\n', 'Method can be non-convergent')
  endif

  x = [1; 0; 0]
  while norm(A * x - b) > eps
    x = invD * (b - R*x)
  end
endfunction


% example usage
A = [2 0 1; 0 1 0; 0 0 1]
b = [1; 2; 3]

x = jacobi(A, b, 1e-10)
