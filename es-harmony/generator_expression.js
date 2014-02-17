function square (seq) {
  return (x*x for (x in seq));
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
