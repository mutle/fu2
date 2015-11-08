var EditorShortcuts = React.createClass({
  buttons: [
    {
      name: "quote", icon: "quote", line: true, action: function(selection) {
        return ["> ", selection];
      }
    },
    {
      name: "image", icon: "file-media", action: function(selection) {
        return ["![](", selection, ")"];
      }
    },
    {
      name: "link", icon: "link-external", action: function(selection) {
        if(selection.match(/:\/\//))
          return ["[", "", "](", selection, ")"];
        else
          return ["[", selection, "](", "", ")"];
      }
    },
    "div",
    {
      name: "bold", title: "B", action: function(selection) {
        return ["**", selection, "**"];
      }
    },
    {
      name: "italic", title: "I", action: function(selection) {
        return ["_", selection, "_"];
      }
    },
    {
      name: "strike", title: "S", action: function(selection) {
        return ["~~", selection, "~~"];
      }
    },
    {
      name: "h2", title: "H", line: true, action: function(selection) {
        return ["## ", selection];
      }
    }
  ],
  buttonClick: function(e) {
    var action = e.target.title;
    if(action == "") action = $(e.target).parents(".editor-button").attr("title");
    for(var b in this.buttons) {
      var button = this.buttons[b];
      if(button == "div") continue;
      if(button.name == action) {
        if(button.line)
          this.props.editor.lineAction(button.action);
        else
          this.props.editor.action(button.action);
      }
    }
    e.preventDefault();
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
      return <span key={button.name} onClick={self.buttonClick} className={className} title={button.name}>{title}</span>;
    });
    return <div className="editor-shortcuts">
      {b}
    </div>;
  }
});
