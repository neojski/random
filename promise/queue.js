var promiseme = require('promiseme');

function logPromise(data) {
  var d = promiseme.deferred();
  setTimeout(function () {
    d.fulfill(data);
  }, Math.random() * 1000);
  return d.promise;
}

function Queue() {
  var d = promiseme.deferred();
  this.promise = d.promise;
  d.fulfill();
}
Queue.prototype.add = function (fun, args) {
  this.promise = this.promise.then(function () {
    return fun.apply(null, args);
  });
};

var log = console.log;

function ask(data) {
  return logPromise(data).then(log);
}

var q = new Queue();
q.add(ask, ['1']);
q.add(ask, ['2']);
q.add(ask, ['3']);
