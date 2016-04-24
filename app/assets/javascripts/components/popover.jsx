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
      var exit = <div className="popover-exit" onClick={this.props.exitCallback} />;
    }
    var className = "popover "+this.props.style;
    var style = {};

    if(!this.relative && this.props.relativeCallback) this.relative = this.props.relativeCallback(this);

    if(this.relative) {
      var rp = $(this.relative).position();
      if(this.props.style == "top-left") {
        if($(document).width() >= 800)
          style["left"] = rp.left;
        else
          style["left"] = 20;
      } else {
        style["left"] = rp.left;
      }
      style["right"] = 20;
    }

    return <div className={className} style={style}>
      {exit}
      {content}
    </div>;
  }
});

// module.exports = Popover;
window.Popover = Popover;
