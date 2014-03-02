// set string o to copied value
o = JSON.parse(o);

var m = {};
Array.prototype.forEach.call(document.getElementsByClassName('course-quiz-question-body'), function (q) {
  m[q.firstElementChild.textContent] = q.getElementsByTagName('textarea')[0];
});
Object.keys(o).forEach(function (name) {
  m[name].value = o[name];
});
