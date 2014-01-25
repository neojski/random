function res = f(x)
  res = exp(x.^2) .* sin(x)
end

% Calculate derivate mathematically
function y = df(x)
  y = (2.*x.*sin(x) .+ cos(x)) .* exp(x.^2)
end

% This guy gives us approximation O(h^2)
% Since:
% f(x+h) = \sum f^{(k)}(x) h^k / k!
% f(x-h) = \sum (-1)^k f^{(k)}(x) h^k / k!
% And so:
% f'(x) = D(x, h) - (f^{(3)}(x) h^2 / 3! + f^{(5)}(x) h^4 / 5! + ... )
% Let's rewrite it as:
% L = D(x, h) + e_2 h^2 + e_3 h^3 + ...
% And now get rid of e_2 somehow:
% L = D(x, 2h) + e_2 (2h)^2 + e_3 (2h)^3 + ...
% We want to get rid of h^2, so...
function v = D(x, h)
  v = (f(x+h) - f(x-h)) / (2*h)
end

% ...we have this one. We can continue this process:
% L = S(x, h) + a_4 h^4 + a_6 h^6 + ...
function v = S(x, h)
  v = (4 * D(x, h) - D(x, 2*h)) / 3
end

% ...and we get this one which is O(h^6) approximation
function v = L(x, h)
  v = (16 * S(x, h) - S(x, 2*h)) / 15
end

hold on
x = linspace(1, 2)
derivative = df(x)
derivative_approx = L(x, 0.1)

plot(x, derivative, 'r-;maths;')
plot(x, derivative_approx, 'g-;richardson;')

pause
