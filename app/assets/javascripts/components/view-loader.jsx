var ViewLoader = React.createClass({
  getInitialState: function() {
    return {view: {}, visible: 0};
  },
  render: function() {
    if(!this.props.count) return null;
    var remaining = this.props.count - this.props.visible;
    if(remaining < 1) return null;
    return <div className="view-loader">
      <a href="#" onClick={this.props.callback}>{remaining} {this.props.message}</a>
    </div>;
  }
});

// module.exports = ViewLoader;
window.ViewLoader = ViewLoader;
