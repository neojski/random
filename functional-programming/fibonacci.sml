fun fibinc (a: IntInf.int) (b: IntInf.int) 0 = a
  | fibinc a b n = fibinc b (a+b) (n-1)
fun fib n = fibinc 0 1 n
