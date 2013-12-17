var f = function(i, name) {
  if (++i < 5) {
    console.log(name, i);
    process.nextTick(function() {f(i, name)});
  }
};

setImmediate(function() {f(0, 'a');});
setImmediate(function() {f(0, 'b');});

// try also
//process.nextTick(function() {f(0, 'a');});
//process.nextTick(function() {f(0, 'b');});
