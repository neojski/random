function rand(a, b) {
  return Math.floor(Math.random() * (b - a + 1)) + a;
}
function tree(size) {
  if (size === 0) {
    return {op: '1'};
  }
  if (size === 1) {
    return {op: rand(0, 1) ? 'a' : 'b'}
  }

  var leftsize = rand(1, size-1);
  var rightsize = size - leftsize;
  var op = rand(0, 2);
  switch (op) {
    case 0:
      // concat
      return {op: '.', left: tree(leftsize), right: tree(rightsize)}
    case 1:
      // +
      return {op: '+', left: tree(leftsize), right: tree(rightsize)}
    case 2:
      // *
      return {op: '*', left: tree(size)}
  }
}

function inorder(tree) {
  var res = [];
  function go(tree) {
    if (tree) {
      go(tree.left);
      go(tree.right);
      res.push(tree.op);
    }
  }
  go(tree);
  return res.join('');
}

console.log(2);

var z = 1; console.log(z);
var n = 3;

function get() {
  return inorder(tree(n));
}

while (z--) {
  console.log(get(), get());
}
