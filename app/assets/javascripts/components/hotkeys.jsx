var Hotkey = React.createClass({
  render: function() {
    var modifiers = [];
    var key = "";
    var keys = this.props.hotkey.split("+");
    key = keys[keys.length - 1].toUpperCase();
    if(keys.length > 1) {
      for(var i = 0; i < keys.length - 1; i++) modifiers.push(keys[i]);
    }
    var modifierKeys = modifiers.map(function(k,i) { return <span className="key">{k}</span>; });
    return <span className="combo">
      {modifierKeys}
      <span className="key">{key}</span>
    </span>;
  }
});

var Hotkeys = React.createClass({
  getInitialState: function() {
    return {show: false};
  },
  close: function(e) {
    e.preventDefault();
    this.setState({show: false});
  },
  hotkeyGroup: function(name, hotkeys) {
    if(hotkeys) {
      var commands = [];
      for(var k in hotkeys) {
        var hk = hotkeys[k];
        var hkname = hk;
        if(!hk.name) {
          if(Router.responders[hk])
            hkname = Router.responders[hk].options.name;
          // hkname = Router.responders[hk];
        } else {
          hkname = hk.name;
        }
        if(hk.hotkey) {
          var hotkey = hk.hotkey;
          if(hotkey && hotkey.name) hkname = hotkey.name;
        }
        if(hk.alternative) {
          var alternatives = hk.alternative.map(function(hk, i) {
            return <span className="alternative"> or <Hotkey hotkey={hk} /></span>;
          });
        }
        var command = <div className="command">
          <Hotkey hotkey={k} />
          {alternatives}
          <span className="label">{hkname}</span>
        </div>;
        commands.push(command);
      }
      return <div>
        <h3>{name} Hotkeys</h3>
        {commands}
      </div>;
    }
    return null;
  },
  render: function() {
    if(!this.state.show) return null;
    var globalCommands = this.hotkeyGroup("Global", Router.hotkeys);
    var localCommands = this.hotkeyGroup(Router.current_name, Router.current.hotkeys());
    var otherCommands = [];
    console.log(Router.hotkey_groups);
    for(var n in Router.hotkey_groups) {
      otherCommands.push(this.hotkeyGroup(n, Router.hotkey_groups[n]));
    }
    return <div className="hotkeys dialog">
      <span className="close octicon octicon-x" onClick={this.close} />
      <div className="content">
        {globalCommands}
        {localCommands}
        {otherCommands}
      </div>
    </div>;
  }
});
