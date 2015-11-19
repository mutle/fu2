var UserList = React.createClass({
  render: function() {
    var count = 0;
    var users = this.props.users.sort(function(a,b) { return a.id - b.id; }).map(function(user,i) {
      if(user.login.indexOf("-disabled") > 0) return null;
      count++;
      return <div className="user-list-user" key={user.id}>
        <UserLink user={user} />
      </div>;
    });
    return <div className="user-list">
      <h2>All Users ({count})</h2>
      <div className="list">
        {users}
      </div>
    </div>;
  }
});

// module.exports = UserList;
window.UserList = UserList;
