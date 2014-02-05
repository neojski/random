var f = function (doc) {
  emit(doc.name, doc);
  console.log(variable);
};

function emitize(f, emit) {
  return new Function('emit', 'doc', 'var x = ' + f.toString() + '; x(doc);');
}


(function () {
  var variable = 'test';

  var emit = function (key, value) {
    console.log(key, value);
  };

  var map = emitize(f, emit);
  map(emit, {name: 'this is some name'});
})();
