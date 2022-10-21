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
  actions.set("label", function () {
    keyCombo("l");
  });
  // add all labels
  [...document.querySelectorAll("a")]
    .filter((x) => x.href.indexOf("label") > -1)
    .map((x) => x.href.slice(x.href.indexOf("#")))
    .forEach(function (label) {
      actions.set(label.replace("#label/", "#"), function () {
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
      this.box.style = "overflow: scroll; max-height: 200px";
      this.selected = 0;
      this.update("");
    }

    computeSuggestions(command) {
      let pattern = new RegExp(command.replaceAll(" ", ".*"));
      let candidates = [...actions].filter(function ([k, v]) {
        return pattern.test(k);
      });
      return candidates;
    }

    render() {
      console.log(this.selected);
      this.box.innerHTML = "";
      let selectedLi;
      for (let i = 0; i < this.suggestions.length; i++) {
        let k = this.suggestions[i][0];
        let li = document.createElement("li");
        li.innerHTML = k;
        if (i === this.selected) {
          li.style = "background: #add8e6";
          selectedLi = li;
        }
        this.box.appendChild(li);
      }
      if (selectedLi) selectedLi.scrollIntoView({ block: "nearest" });
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

  class Input {
    constructor() {
      this.box = document.createElement("div");
      this.box.style =
        "position: relative; width: 100%; font-size: 25px; box-sizing: border-box; overflow: hidden";
      this.typeahead = document.createElement("div");
      this.typeahead.style = "position: absolute; top: 0; left: 0; color: grey";
      this.box.appendChild(this.typeahead);
      this.form = document.createElement("form");
      this.box.appendChild(this.form);
      this.input = document.createElement("input");
      this.input.style =
        "background: transparent; border: 0; margin: 0; padding: 0; position: relative";
      this.form.appendChild(this.input);
    }
    setSuggestion([suggestion]) {
      if (suggestion.startsWith(this.getInput())) {
        this.typeahead.innerHTML = suggestion; // TODO: lazy impl
      } else {
        this.typeahead.innerHTML = "";
      }
    }
    getBox() {
      return this.box;
    }
    getInput() {
      return this.input.value;
    }
    focus() {
      this.input.focus();
    }
    onsubmit(f) {
      this.form.onsubmit = f;
    }
    onchange(f) {
      this.input.onkeyup = f;
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

  function run() {
    if (box) {
      close();
      return;
    }
    box = document.createElement("div");
    let input = new Input();
    box.appendChild(input.getBox());
    box.appendChild(suggestions.getBox());
    input.onchange(function () {
      suggestions.update(input.getInput());
      input.setSuggestion(suggestions.getSelected());
    });
    document.body.appendChild(box);
    box.style =
      "position: absolute; top: 50%; left: 50%; width:400px; transform: translate(-50%, -50%); background: white; padding: 40px; border-radius: 20px; z-index: 1000; box-shadow: rgba(100, 100, 111, 0.2) 0px 7px 29px 0px;";
    input.focus();
    input.onsubmit(function () {
      close();
      let suggestion = suggestions.getSelected();
      if (suggestion) {
        submit(suggestions.getSelected());
      }
      return false;
    });
  }
  document.onkeydown = function (e) {
    if (e.ctrlKey && e.key === "k") {
      run();
      return false;
    }
    if (box) {
      if (e.key === "ArrowUp") {
        suggestions.prevSelected();
        return false;
      }
      if (e.key === "ArrowDown") {
        suggestions.nextSelected();
        return false;
      }
      if (e.key === "Escape") {
        close();
        return false;
      }
    }
  };
})();
