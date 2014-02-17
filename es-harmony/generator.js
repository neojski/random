function Range (from, to) {
  this.from = from;
  this.to = to;
}
Range.prototype.__iterator__ = function () {
  for (var i = this.from; i <= this.to; i++) {
    yield i;
  }
};
var range = new Range(2, 10);
for (var i in range) {
  console.log(i);
}
