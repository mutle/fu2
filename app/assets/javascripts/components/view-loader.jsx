var ViewLoader = React.createClass({
  getInitialState: function() {
    return {view: {}, visible: 0};
  },
  render: function() {
    if(!this.props.count) return null;
    var remaining = this.props.count - this.props.visible;
    if(remaining < 1) return null;
    return <span onClick={this.props.callback}>{remaining} {this.props.message}</span>;
  }
});

// module.exports = ViewLoader;
window.ViewLoader = ViewLoader;
