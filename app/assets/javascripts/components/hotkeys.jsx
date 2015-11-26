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
  render: function() {
    if(!this.state.show) return null;
    var globalCommands = [];
    var localCommands = [];
    for(var k in Router.hotkeys) {
      var responder = Router.hotkeys[k];
      var r = Router.responders[responder];
      var command = <div className="command">
        <Hotkey hotkey={k} />
        <span className="label">{r.options.name}</span>
      </div>;
      globalCommands.push(command);
    }
    if(Router.current.hotkeys) {
      var localHotkeys = Router.current.hotkeys();
      if(localHotkeys) {
        for(var k in localHotkeys) {
          var hotkey = localHotkeys[k];
          if(hotkey.alternative) {
            var alternatives = hotkey.alternative.map(function(hk, i) {
              return <span className="alternative"> or <Hotkey hotkey={hk} /></span>;
            });
          }
          var command = <div className="command">
            <Hotkey hotkey={k} />
            {alternatives}
            <span className="label">{hotkey.name}</span>
          </div>;
          localCommands.push(command);
        }
        var local = <div>
          <h3>{Router.current_name} Hotkeys</h3>
          {localCommands}
        </div>;
      }
    }
    return <div className="hotkeys dialog">
      <span className="close octicon octicon-x" onClick={this.close} />
      <div className="content">
        <h3>Global Hotkeys</h3>
        {globalCommands}
        {local}
      </div>
    </div>;
  }
});
