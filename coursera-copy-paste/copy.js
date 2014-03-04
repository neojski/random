var o = {};
var qs = document.getElementsByClassName('course-quiz-question-body');
for (var i = 0; i < qs.length; i++) {
  var q = qs[i];

  var nr = q.firstElementChild.textContent.trim();
  var c;
  if (c = q.getElementsByTagName('textarea')[0]) {
    o[nr] = c.value.trim();
  } else if (c = q.querySelector('.course-quiz-student-answer')) {
    o[nr] = c.textContent.trim();
  }
}
console.log("var o = '" + JSON.stringify(o) + "'");
