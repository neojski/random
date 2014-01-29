function Q = bezier(P, t)
  for k=1:length(t)
    Q(:,k) = [0 0];
    for j=1:size(P,2)
      Q(:,k) += P(:,j) * Bernstein(size(P,2)-1,j-1,t(k));
    end
  end
end

function B = Bernstein(n, j, t)
  B = nchoosek(n,j)*(t^j)*(1-t)^(n-j);
end

P = [3 1.75 0.9 0 0.5 1.5 3.25 4.25 4.25 3 3.75 6;
4 1.60 0.5 0 1.0 0.5 0.5 2.25 4.0 4.0 3.25 4.25]

t = linspace(0,1)
curve = bezier(P, t)

plot(curve(1,:), curve(2,:), 'b', 'LineWidth', 2),

P = [1 2 3 2 1.2 2 2.7;
1 0 1 2.5 3.4 4 3.2]
curve = bezier(P, t)

hold on
plot(curve(1,:), curve(2,:), 'r', 'LineWidth', 2),
pause
