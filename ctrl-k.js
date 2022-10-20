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
  actions.set("#money-stuff", function () {
    keyCombo("gigl");
    let search = document.querySelector("#gs_taif50").previousElementSibling;
    search.focus();
    setTimeout(function () {
      // Looks like this doesn't work due to isTrusted property, see:
      // https://developer.mozilla.org/en-US/docs/Web/API/Event/isTrusted
      search.dispatchEvent(new KeyboardEvent("keydown", { key: k })); // I can't figure out why this doesn't work
    }, 100);
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
      let candidates = [...actions].filter(function ([k, v]) {
        return k.indexOf(command) > -1;
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
      this.selected =
        (this.selected + i + this.suggestions.length) % this.suggestions.length;
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
      submit(suggestions.getSelected());
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
