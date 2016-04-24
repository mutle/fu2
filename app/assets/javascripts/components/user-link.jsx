var UserLink = React.createClass({
  getInitialState: function() {
    return {showPopover: false};
  },
  render: function() {
    if(!this.props.user) return null;
    var userLink = Data.url_root + "/users/"+this.props.user.id;
    var name = {__html: this.props.user.display_name_html.replace(/<\/?p>/g, '')};
    // onMouseOver={this.over} onMouseOut={this.out}
    // <Popover style={"mouse-over"} local={true} show={this.state.showPopover} renderCallback={this.renderUserShow} />
    return <div className="user-link">
      <a className="avatar" href={userLink}><img className="avatar-image" src={this.props.user.avatar_url} width="32" height="32" /></a>
      <span className="user-name" dangerouslySetInnerHTML={name} />
    </div>;
  },
  renderUserShow: function() {
    return <UserProfile userId={this.props.user.id} small={true} />
  },
  over: function(e) {
    if(!this.state.showPopover)
      this.setState({showPopover: true});
  },
  out: function(e) {
    if(this.state.showPopover)
      this.setState({showPopover: false});
  }
});

// module.exports = UserLink;
window.UserLink = UserLink;
