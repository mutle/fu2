var EditorShortcuts = React.createClass({
  buttons: [
    {
      name: "quote", icon: "quote", hotkey: "ctrl+q", line: true, action: function(selection) {
        return ["> ", selection];
      }, description: "Quote"
    },
    {
      name: "image", icon: "file-media", hotkey: "ctrl+i", action: function(selection) {
        return ["![](", selection, ")"];
      }, description: "Insert Image"
    },
    {
      name: "link", icon: "link-external", hotkey: "ctrl+l", action: function(selection) {
        if(selection.match(/:\/\//))
          return ["[", "", "](", selection, ")"];
        else
          return ["[", selection, "](", "", ")"];
      }, description: "Insert Link"
    },
    "div",
    {
      name: "bold", title: "B", hotkey: "ctrl+b", action: function(selection) {
        return ["**", selection, "**"];
      }, description: "Bold"
    },
    {
      name: "italic", title: "I", hotkey: "ctrl+i", action: function(selection) {
        return ["_", selection, "_"];
      }, description: "Italic"
    },
    {
      name: "strike", title: "S", hotkey: "ctrl+s", action: function(selection) {
        return ["~~", selection, "~~"];
      }, description: "Strike through"
    },
    {
      name: "h2", title: "H", hotkey: "ctrl+h", line: true, action: function(selection) {
        return ["## ", selection];
      }, description: "Header"
    }
  ],
  execCommand: function(action) {
    console.log(action);
    for(var b in this.buttons) {
      var button = this.buttons[b];
      if(button == "div") continue;
      if(button.name == action) {
        console.log(button);
        if(button.line)
          this.props.editor.lineAction(button.action);
        else
          this.props.editor.action(button.action);
      }
    }
  },
  buttonClick: function(e) {
    var action = $(e.target).data("editor-action");
    if(!action)
      action = $(e.target).parents(".editor-button").data("editor-action");
    this.execCommand(action);
    e.preventDefault();
  },
  hotkeys: function() {
    var keys = {};
    for(var k in this.buttons) {
      var button = this.buttons[k];
      (function(button) {
        if(button && button != "div" && button.hotkey) {
          keys[button.hotkey] = {
            name: button.description,
            callback: function(e) {
              this.execCommand(button.name);
            },
            hotkey: button
          };
        }
      })(button);
    }
    console.log(keys);
    return keys;
  },
  componentDidMount: function() {
    Router.bindKeys(this.hotkeys(), false, this, "Editor", $(this.props.editor.getDOMNode()).find("textarea"));
  },
  componentWillUnmount: function() {
    Router.unbindKeys(Router.hotkey_groups["editor"], this, $(this.props.editor.getDOMNode()).find("textarea"));
    Router.hotkey_groups["editor"] = null;
  },
  render: function() {
    var self = this;
    var b = this.buttons.map(function(button, i) {
      if(button == "div") return <span key={"div-"+i} className="divider" />;
      var className = "editor-button button-"+button.name
      if(button.icon) {
        var oc = "octicon octicon-"+button.icon;
        var title = <span className={oc} />;
      } else
        var title = button.title;
      return <span key={button.name} onClick={self.buttonClick} className={className} title={button.description} data-editor-action={button.name}>{title}</span>;
    });
    return <div className="editor-shortcuts">
      {b}
    </div>;
  }
});
