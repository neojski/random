% The required function is equal to the simpler one:
% -0.5 sin(2x) (cos x - sin x) =
% -0.5 sin(2x) sqrt(2) sin(pi/4 - x)
% We can have a numeric problem for x ~ pi/4 - x
% But near that numer we can just use equality:
% sin(pi/4 - x) = cos(x + pi/4)
% As a result we can just use:
% -0.5 sin(2x) sqrt(2) sin(pi/4 - x) for x <= 0
% -0.5 sin(2x) sqrt(2) cos(pi/4 + x) for x >= 0

function res = better(x)
  res = -0.5 .* sin(2 .* x) .* sqrt(2)
  if x <= 0
    res .*= sin(pi/4 - x)
  else
    res .*= cos(pi/4 + x)
  end
end

function res = naive(x)
  res = (sin(x).^2) .* cos(x) - (cos(x).^2) .* sin(x)
end

x = linspace(pi/4 - .5, pi/4 + .5, 1000)
plot(x, abs(better(x) - naive(x)) ./ better(x))
pause
