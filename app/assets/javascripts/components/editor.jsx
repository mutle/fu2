window.Slashcommands = [
  {title: "ascii ", description: "/ascii <text>"},
  {title: "deploy ", description: "/deploy <branch>"},
  {title: "image ", description: "/image <key words>"},
  {title: "gif ", description: "/gif <key words>"},
  {title: "remember ", description: "/remember <user> is <title>"},
  {title: "roll ", description: "/roll, /roll 3d6"},
  {title: "stock ", description: "/stock <symbol>"},
  {title: "who is ", description: "/who is <user>"}
];

var Editor = React.createClass({
  getInitialState: function() {
    return {text: "", active: false, textSelection: null, autocomplete: null, objects: [], filtered: [], input: "", start: null, selection: 0};
  },
  getInitialProps: function() {
    return {valueName: "text"};
  },
  insertImage: function(url, prefix) {
    this.insert("![]("+url+")");
  },
  insert: function(text, prefix) {
    var s = $(this.getDOMNode()).find("."+this.props.textareaClass).get(0).value;
    if(prefix && s.length > 0) s += prefix;
    s += text;
    this.setState({text: s});
    $(this.getDOMNode()).find("."+this.props.textareaClass).focus();
  },
  action: function(a) {
    var c = $(this.getDOMNode()).find("."+this.props.textareaClass).get(0);
    var cursorE = c.selectionEnd;
    var cursorS = c.selectionStart;
    var selected = c.value.slice(cursorS, cursorE);
    var out = a(selected);
    var newtext = c.value.slice(0, cursorS) + out.join("") + c.value.slice(cursorE, c.value.length);
    var newCursor = cursorS;
    for(var o in out) {
      if(out[o] == "") break;
      newCursor += out[o].length;
    }
    this.setState({text: newtext, textSelection: [newCursor, newCursor], active: true});
  },
  lineAction: function(a) {
    var c = $(this.getDOMNode()).find("."+this.props.textareaClass).get(0);
    var cursorE = c.selectionEnd;
    var cursorS = c.selectionStart;
    var v = c.value;
    while(cursorS > 0 && v[cursorS-1] != "\n") {
      cursorS--;
    }
    while(cursorE < v.length && v[cursorE+1] != "\n") {
      cursorE++;
    }
    var out = c.value.slice(cursorS, cursorE).split("\n").map(function(s,i) { return a(s).join(""); });
    var newtext = c.value.slice(0, cursorS) + out.join("\n") + c.value.slice(cursorE, c.value.length);
    var newCursor = cursorS + out.join("").length;
    this.setState({text: newtext, textSelection: [newCursor, newCursor], active: true});
  },
  input: function(e) {
    var cursorE = $(this.getDOMNode()).find("."+this.props.textareaClass).get(0).selectionEnd;
    var cursorS = $(this.getDOMNode()).find("."+this.props.textareaClass).get(0).selectionStart;

    if(this.state.autocomplete && cursorE < this.state.start) {
      this.setState({autocomplete: null});
    }
    switch(e.key) {
      case "Escape":
      case " ":
        this.setState({autocomplete: null});
        break;
      case "Enter":
        if(e.ctrlKey || e.metaKey) {
          if(this.props.submit && this.state.text.length > 0)
            this.props.submit(e);
          e.preventDefault();
        } else if(this.state.autocomplete) {
          e.preventDefault();
          var result = this.state.filtered[this.state.selection];
          if(result) {
            if(result.login) result = result.login;
            if(result.title) result = result.title;
            var extra = this.state.autocomplete == "emoji" ? ":" : "";
            var input = e.target.value.slice(0, this.state.start) + result + extra + e.target.value.slice(cursorE, e.target.value.length);
            e.target.value = input;
            var cursor = this.state.start + result.length + extra.length;
            this.setState({autocomplete: null, text: input});
          } else {
            this.setState({autocomplete: null});
          }
        }
        break;
      case "ArrowUp":
        if(this.state.autocomplete) {
          e.preventDefault();
          var v = this.state.selection - 1;
          if(v < 0) v = 0;
          this.setState({selection: v});
        }
        break;
      case "ArrowDown":
        if(this.state.autocomplete) {
          e.preventDefault();
          var v = this.state.selection + 1;
          if(v >= this.state.filtered.length) v = this.state.filtered.length - 1;
          this.setState({selection: v});
        }
        break;
      case ":":
        if(this.state.autocomplete)
          this.setState({autocomplete: null});
        else
          this.setState({autocomplete: "emoji", selection: 0, objects: window.Emojis, filtered: this.filterObjects("", window.Emojis), input: "", start: cursorE+1});
        break;
      case "@":
        this.setState({autocomplete: "users", selection: 0, objects: window.Users, filtered: this.filterObjects("", window.Users), input: "", start: cursorE+1});
        break;
      case "/":
        if(cursorS == 0)
          this.setState({autocomplete: "slash", selection: 0, objects: window.Slashcommands, filtered: this.filterObjects("", window.Slashcommands), input: "", start: cursorE+1});
        break;
    }
    if(this.state.autocomplete) {
      var key = e.key;
      var ce = cursorE;
      if(key == "Backspace") {
        ce -= 1;
        key = "";
      }
      if(key.length <= 1) {
        if(ce < this.state.start) ce = this.state.start;
        var input = e.target.value.slice(this.state.start, ce);
        var text = input + key;

        this.setState({input: text, filtered: this.filterObjects(text), selection: 0, autocomplete: ce < this.state.start ? null : this.state.autocomplete});
      }
    }

    if(e.type == "keypress") this.change();
  },
  change: function(e) {
    if(e) this.setState({text: e.target.value});

    var c = $(this.getDOMNode()).find("."+this.props.textareaClass).get(0);
  },
  click: function(e) {
  },
  autocompleteClick: function(e) {
    if(this.state.autocomplete) {
      var text = $(this.getDOMNode()).find("."+this.props.textareaClass);
      var cursorE = text.get(0).selectionEnd;
      var s = text.val();
      var value = $(e.target).parents(".result").data("value");
      var input = s.slice(0, this.state.start) + value + (this.state.autocomplete == "emoji" ? ":" : "") + s.slice(cursorE, s.length);
      e.target.value = input;
      this.setState({autocomplete: null, text: input});
      text.focus();
    }
  },
  blur: function(e) {
    e.preventDefault();
    this.setState({active: false});
  },
  filterObjects: function(input, objects) {
    var n = 0;
    if(!objects) objects = this.state.objects;
    var filtered = [];
    input = input.toLowerCase();
    if(objects[0].aliases) {
      var sorted = [];
      var emoji = {};
      objects.map(function(r,i) {
        sorted.push(r.aliases[0]);
        emoji[r.aliases[0]] = r;
      });
      sorted = sorted.sort();
      for(var i in sorted) {
        var k = sorted[i];
        if(n < 10 && (input.length < 1 || k.indexOf(input) === 0)) {
          n++;
          filtered.push({title: k, image: emoji[k].image, description: emoji[k].tags.join(", ")});
        }
      }
      if(n < 10) {
        for(var i in sorted) {
          var k = sorted[i];
          for(var t in emoji[k].tags) {
            var tag = emoji[k].tags[t];
            if(n < 10 && (input.length < 1 || tag.indexOf(input) === 0)) {
              n++;
              filtered.push({title: k, image: emoji[k].image, description: emoji[k].tags.join(", ")});
            }
          }
        }
      }
    } else {
      objects.map(function(r, i) {
        var s = r;
        if(r.login) s = r.login;
        if(r.title) s = r.title;
        s = s.toLowerCase();
        if(n < 10 && (input.length < 1 || s.indexOf(input) === 0)) {
          n++;
          filtered.push(r);
        }
      });
    }
    return filtered;
  },
  componentDidMount: function() {
    if(this.state.text === "" && this.props.initialText)
      this.setState({text: this.props.initialText});
  },
  componentDidUpdate: function() {
    if(this.isMounted() && this.state.active) {
      var c = $(this.getDOMNode()).find("."+this.props.textareaClass).get(0);
      c.focus();
      if(this.state.textSelection != null) {
        c.setSelectionRange(this.state.textSelection[0], this.state.textSelection[1]);
        this.setState({textSelection: null});
      }
    }
  },
  render: function() {
    if(this.state.autocomplete) {
      var autocompleter = <AutoCompleter objects={this.state.filtered} selection={this.state.selection} clickCallback={this.autocompleteClick} />;
    }
    return <div>
      {autocompleter}
      <EditorShortcuts editor={this} />
      <textarea onBlur={this.blur} onKeyDown={this.input} onKeyPress={this.input} onMouseDown={this.click} onChange={this.change} className={this.props.textareaClass} name={this.props.valueName} id={this.props.textareaId} value={this.state.text}></textarea>
    </div>;
  }
});

// module.exports = Editor
window.Editor = Editor;
