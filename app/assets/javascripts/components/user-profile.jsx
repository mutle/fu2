var UserProfile = React.createClass({
  componentWillMount: function() {
    var user = Data.get("user", parseInt(this.props.userId));
    if(user) {
      this.user = user;
    } else {
      for(var u in window.Users) {
        user = window.Users[u];
        if(user.login == this.props.userId) {
          this.user = user;
          break;
        }
      }
    }
  },
  render: function() {
    console.log(this.props.userId);
    if(this.user) {
      var name = {__html: this.user.display_name};
      return <div className="user-profile">
        <h2>{name}</h2>

        Member since {formatTimestamp(this.user.created_at)}
      </div>;
    } else {
      var message = "User "+this.props.userId+" not found"
      return <ErrorMessage title={message} />;
    }
  }
});

// module.exports = UserProfile;
window.UserProfile = UserProfile;
