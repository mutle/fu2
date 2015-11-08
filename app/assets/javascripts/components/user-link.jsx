var UserLink = React.createClass({
  render: function() {
    var userLink = "/users/"+this.props.user.id;
    var name = {__html: this.props.user.display_name};
    return <div className="user-link">
      <a className="avatar" href={userLink}><img className="avatar-image" src={this.props.user.avatar_url} /></a>
      <span className="user-name" dangerouslySetInnerHTML={name} />
    </div>;
  }
});

// module.exports = UserLink;
window.UserLink = UserLink;
