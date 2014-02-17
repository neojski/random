// generator expression
function square (seq) {
  return (x*x for (x of seq));
}
// or traditional way
function cube (seq) {
  for (var x of seq) {
    yield x*x*x;
  }
}
function seq() {
  for (let i = 0;;) yield i++;
}

for (let x of square(seq())) {
  if (x > 1000) {
    break;
  }
  console.log(x);
}
