function v = f(x)
	v = cot(3*x) - (x^2-1)/(2*x);
end

function v = df(x)
	v = -1/(2*x^2) - 3*csc(3*x) - 1/2;
end

function res = g(x)
	res = (x*sec(x)^2 - 2*tan(x))/x^3;
end

function c = bisection(f, a, b, eps)
	while abs(b - a) > eps
		c = (a+b)/2;
		if f(a)*f(c) < 0
			b = c;
		else
			a = c;
		end
	end
end

function b = secant(f, a, b, eps)
	while abs(a - b) > eps
		c = b - (f(b)*(b-a)) / (f(b)-f(a));
		a = b;
		b = c;
	end
end

function x = falsi(f, a, b, iter)
	x = (a*f(b)-b*f(a))/(f(b)-f(a));
	while --iter
		if f(a)*f(x) <= 0
			x = (x*f(a)-a*f(x)) / (f(a)-f(x));
		else
			x = (x*f(b)-b*f(x)) / (f(b)-f(x));
		end
	end
end

function x = newton(f, a, b, iter)
	x = a;
	while --iter
		x = x - f(x)/df(x);
	end
end

% 1, 2
a = 0.5;
b = 1;
bisection(@f, a, b, eps)
secant(@f, a, b, eps)
falsi(@f, a, b, 100)
newton(@f, a, b, 100)

% 3
bisection(@g, 0.5, 1, eps)
