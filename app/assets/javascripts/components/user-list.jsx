var UserList = React.createClass({
  render: function() {
    var count = 0;
    var sorted = null;
    if(this.props.sort) {
      sorted = this.props.sort(this.props.users);
    } else {
      sorted = this.props.users.sort(function(a,b) { return a.id - b.id; });
    }
    var info = this.props.info;
    var users = sorted.map(function(user,i) {
      if(user.login.indexOf("-disabled") > 0) return null;
      count++;
      if(info) {
        var user_info = info[user.id];
      }
      return <div className="user-list-user" key={user.id}>
        <UserLink user={user} extra={user_info} />
      </div>;
    });
    if(!this.props.hideHeader) {
      var header = <h2>All Users ({count})</h2>;
    }
    return <div className="user-list">
      {header}
      <div className="list">
        {users}
      </div>
    </div>;
  }
});

// module.exports = UserList;
window.UserList = UserList;
