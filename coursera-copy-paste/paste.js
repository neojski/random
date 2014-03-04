// set string o to copied value
o = JSON.parse(o);

var qs = document.getElementsByClassName('course-quiz-question-body');
for (var i = 0; i < qs.length; i++) {
  var q = qs[i];

  var nr = q.firstElementChild.textContent.trim();
  var c;
  if (c = q.getElementsByTagName('textarea')[0]) {
    c.value = o[nr];
  } else if (c = q.querySelector('.course-quiz-options')) {
    var acceptableLabels = Array.prototype.filter.call(
      c.getElementsByTagName('label'),
      function (label) {
        return (label.textContent.trim() === o[nr]);
      }
    );
    if (acceptableLabels.length === 1) {
      var label = acceptableLabels[0];
      var radio = document.getElementById(label.htmlFor);
      radio.checked = true;
    } else if (o[nr]) {
      console.log('Can\'t set radio in question ' + nr);
    }
  }
}
