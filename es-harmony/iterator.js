function Range (from, to) {
  this.from = from;
  this.to = to;
}

function RangeIterator (r) {
  this.range = r;
  this.current = r.from;
}
RangeIterator.prototype.next = function () {
  if (this.current > this.range.to) {
    throw StopIteration;
  } else {
    return this.current++;
  }
}
Range.prototype.__iterator__ = function () {
  return new RangeIterator(this);
};

var range = new Range(2, 10);
for (let i in range) {
  console.log(i);
}

