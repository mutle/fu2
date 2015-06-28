var FaveCounter = React.createClass({
  getInitialState: function() {
    return {faves: []};
  },
  render: function() {
    var icon = <span className="octicon octicon-star" />;
    if(!this.state.faves || this.state.faves.length == 0) return <span>{icon}{'0'}</span>;
    return <span title={this.state.faves.join(", ")}>{icon}{this.state.faves.length}</span>;
  }
});

$(function() {
  $(".channel-post .faves").each(function(i, fave) {
    var f = React.render(<FaveCounter />, fave);
    f.setState({faves: $(fave).data("faves")});
  });
});
