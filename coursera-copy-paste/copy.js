var o = {};
var qs = document.getElementsByClassName('course-quiz-question-body');
for (var i = 0; i < qs.length; i++) {
  var q = qs[i];

  var nr = q.firstElementChild.textContent;
  // TODO: checkbox
  var value = (q.getElementsByTagName('textarea')[0] || {}).value;

  o[nr] = value;
}
console.log(JSON.stringify(o));
