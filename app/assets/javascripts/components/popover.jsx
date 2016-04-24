var Popover = React.createClass({
  componentDidMount: function() {
    if(this.props.mountCallback) {
      this.props.mountCallback(this);
    }
  },
  render: function() {
    if(!this.props.show) return <span></span>;
    if(this.props.renderCallback) {
      var content = this.props.renderCallback(this);
      if(!this.props.local)
        var exit = <div className="popover-exit" onClick={this.props.exitCallback} />;
    }
    var className = "popover "+this.props.style;
    var style = {};

    if(this.props.relativeCallback) {
      style = this.props.relativeCallback(this, style);
    }

    return <div className={className} style={style}>
      {exit}
      {content}
    </div>;
  }
});

// module.exports = Popover;
window.Popover = Popover;
