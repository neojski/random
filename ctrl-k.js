(function () {
  const actions = new Map();
  function keyCombo(combo) {
    for (let k of combo) {
      document.dispatchEvent(new KeyboardEvent("keydown", { key: k }));
    }
  }
  actions.set("snooze", function () {
    keyCombo("b");
  });
  actions.set("snoozed", function () {
    keyCombo("gb");
  });
  actions.set("inbox", function () {
    keyCombo("gi");
  });
  actions.set("sent", function () {
    keyCombo("gt");
  });
  actions.set("starred", function () {
    keyCombo("gs");
  });
  actions.set("all", function () {
    keyCombo("ga");
  });
  actions.set("go to label", function () {
    keyCombo("gl");
  });
  actions.set("label", function () {
    keyCombo("l");
  });
  // add all labels
  [...document.querySelectorAll("a")]
    .filter((x) => x.href.indexOf("label") > -1)
    .map((x) => x.href.slice(x.href.indexOf("#")))
    .forEach(function (label) {
      actions.set(label, function () {
        // Looks like this doesn't work due to isTrusted property, see:
        // https://developer.mozilla.org/en-US/docs/Web/API/Event/isTrusted
        // It may be possible to make this work with a browser extension:
        // https://chromedevtools.github.io/devtools-protocol/tot/Input/#method-dispatchKeyEvent
        window.location.hash = label;
      });
    });
  actions.set("select all", function () {
    keyCombo("*a");
  });

  submit = function ([k, action]) {
    action();
    console.log("ran action", k);
  };
  class Suggestions {
    constructor() {
      this.box = document.createElement("div");
      this.selected = 0;
    }

    computeSuggestions(command) {
      let pattern = new RegExp(command.replaceAll(" ", ".*"));
      let candidates = [...actions].filter(function ([k, v]) {
        return pattern.test(k);
      });
      return candidates;
    }

    render() {
      this.box.innerHTML = "";
      for (let i = 0; i < this.suggestions.length; i++) {
        let k = this.suggestions[i][0];
        let li = document.createElement("li");
        li.innerHTML = k;
        if (i === this.selected) {
          li.style = "background: #add8e6";
        }
        this.box.appendChild(li);
      }
    }

    update(command) {
      this.command = command;
      this.suggestions = this.computeSuggestions(command);
      this.nextPrevSelected(0);
      this.render();
    }

    getBox() {
      return this.box;
    }

    nextPrevSelected(i) {
      if (this.suggestions.length > 0) {
        this.selected =
          (this.selected + i + this.suggestions.length) %
          this.suggestions.length;
      }
      this.render();
    }

    nextSelected() {
      this.nextPrevSelected(1);
    }

    prevSelected() {
      this.nextPrevSelected(-1);
    }

    getSelected() {
      return this.suggestions[this.selected]; // TODO: select with arrows and mouse
    }
  }

  let suggestions = new Suggestions();
  let box;

  function close() {
    if (box) {
      box.parentNode.removeChild(box);
    }
    box = null;
  }

  f = function () {
    box = document.createElement("div");
    let form = document.createElement("form");
    box.appendChild(form);
    box.appendChild(suggestions.getBox());
    let input = document.createElement("input");
    input.onkeyup = function () {
      suggestions.update(input.value);
    };
    form.appendChild(input);
    document.body.appendChild(box);
    box.style =
      "position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); background: white; padding: 40px; border-radius: 20px; z-index: 1000";
    input.focus();
    form.onsubmit = function () {
      close();
      let suggestion = suggestions.getSelected();
      if (suggestion) {
        submit(suggestions.getSelected());
      }
      return false;
    };
  };
  document.onkeydown = function (e) {
    if (e.ctrlKey && e.key === "k") {
      f();
      return false;
    }
    if (e.key === "ArrowUp") {
      suggestions.prevSelected();
    }
    if (e.key === "ArrowDown") {
      suggestions.nextSelected();
    }
    if (e.key === "Escape") {
      close();
    }
  };
})();
