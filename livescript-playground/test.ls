_ = require 'prelude-ls'

# |> = pipe
[1,2,3,4] |> _.map (*2) |> console.log

# (* 2) = function multiplying by two
#  . = function composition
2 |> (* 2) . (+ 2) |> console.log

# ((1+2) + 3) ... + 5 = 15
console.log _.fold (+), 0, [1 to 5]

# crazy stuff: http://livescript.net/blog/fizzbuzzbazz.html
[1 to 100]map ->[k+\zz for k,v of{Fi:3,Bu:5,Ba:7}|it%v<1]0||it
