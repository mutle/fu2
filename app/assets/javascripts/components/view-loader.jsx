var ViewLoader = React.createClass({
  getInitialState: function() {
    return {view: {}, visible: 0};
  },
  render: function() {
    if(!this.props.count) return null;
    var remaining = this.props.count - this.props.visible;
    var all = "";
    if(this.props.messageAll) {
      all = <a href="#" className="load-all" onClick={this.props.callbackAll}>{this.props.messageAll}</a>;
    }
    var octicon = "";
    if(this.props.octicon) {
      var className = "octicon octicon-"+this.props.octicon;
      octicon = <span className={className} />;
    }
    if(remaining < 1) return null;
    return <div className="view-loader">
      <a href="#" onClick={this.props.callback}>{octicon}{remaining} {this.props.message}</a>
      {all}
    </div>;
  }
});

// module.exports = ViewLoader;
window.ViewLoader = ViewLoader;
