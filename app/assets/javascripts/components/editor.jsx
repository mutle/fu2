var Editor = React.createClass({
  getInitialState: function() {
    return {text: "", autocomplete: null, objects: [], filtered: [], input: "", start: null, selection: 0};
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
    this.setState({text: newtext});
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
    this.setState({text: newtext});
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
          this.submit(e);
        } else if(this.state.autocomplete) {
          e.preventDefault();
          var result = this.state.filtered[this.state.selection];
          if(result) {
            if(result.login) result = result.login;
            var input = e.target.value.slice(0, this.state.start) + result + (this.state.autocomplete == "emoji" ? ":" : "") + e.target.value.slice(cursorE, e.target.value.length);
            e.target.value = input;
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
    }
    if(this.state.autocomplete) {
      var key = e.key;
      if(key == "Backspace") {
        cursorE -= 2;
        key = "";
      }
      if(key.length <= 1) {
        var input = e.target.value.slice(this.state.start, cursorE+1) + key;
        this.setState({input: input, filtered: this.filterObjects(input), selection: 0});
      }
    }
  },
  change: function(e) {
    this.setState({text: e.target.value});
  },
  autocompleteClick: function(e) {
    if(this.state.autocomplete) {
      var text = $(this.getDOMNode()).find("."+this.props.textareaClass);
      var cursorE = text.get(0).selectionEnd;
      var s = text.val();
      var value = $(e.target).parents(".result").data("value");
      var input = s.slice(0, this.state.autocompletestart) + value + (this.state.autocomplete == "emoji" ? ":" : "") + s.slice(cursorE, s.length);
      e.target.value = input;
      this.setState({autocomplete: null, text: input});
      text.focus();
    }
  },
  blur: function(e) {
    this.setState({autocomplete: null, text: $("."+this.props.textareaClass).val()});
  },
  filterObjects: function(input, objects) {
    var n = 0;
    if(!objects) objects = this.state.objects;
    var filtered = [];
    input = input.toLowerCase();
    objects.map(function(r, i) {
      var s = r;
      if(r.login) s = r.login;
      s = s.toLowerCase();
      if(n < 10 && (input.length < 1 || s.indexOf(input) === 0)) {
        n++;
        filtered.push(r);
      }
    });
    return filtered;
  },
  componentDidMount: function() {
    if(this.state.text === "" && this.props.initialText)
      this.setState({text: this.props.initialText});
  },
  render: function() {
    var imageUrl;
    if(this.state.autocomplete) {
      if(this.state.autocomplete == "emoji") imageUrl = function(s) { return "/images/emoji/"+s+".png"; };
      var autocompleter = <AutoCompleter objects={this.state.filtered} selection={this.state.selection} imageUrl={imageUrl} clickCallback={this.autocompleteClick} />;
    }
    return <div>
      {autocompleter}
      <EditorShortcuts editor={this} />
      <textarea onBlur={this.blur} onKeyDown={this.input} onKeyPress={this.input} onChange={this.change} className={this.props.textareaClass} name={this.props.valueName} id={this.props.textareaId} value={this.state.text}></textarea>
    </div>;
  }
});

// module.exports = Editor
window.Editor = Editor;
