var user_id = 0;

var NotificationUser = React.createClass({
  render: function() {
    var showMessageClass = "indicator message" + (this.props.countMessages > 0 ? " show" : "");
    var showMentionClass = "indicator mention" + (this.props.countMentions > 0 ? " show" : "");
    var className = "user" + (this.props.active ? " active" : "");
    return <li className={className}>
      <div className={showMessageClass}>{this.props.countMessages}</div>
      <div className={showMentionClass}>{this.props.countMentions}</div>
      <img className="avatar" src={this.props.avatarUrl} />

      <span className="name">{this.props.name}</span>
    </li>;
  }
});

var NotificationUserList = React.createClass({
  render: function() {
    var showUser = function(user, index) {
      if(!user) return null;
      return <NotificationUser id={user.id} key={user.id} name={user.login} countMessages={user.messages} countMentions={user.mentions} avatarUrl={user.avatar_url} active={user.active} />
    };
    console.log(this.props.users);
    return <ul className='users'>
      <li className="divider divider-top">Conversations</li>
      {this.props.activeUsers.map(showUser)}
      <li className="divider">No history yet</li>
      {this.props.inactiveUsers.map(showUser)}
    </ul>;
  }
});

var NotificationResponse = React.createClass({
  render: function() {
    return <div className='response'>
      <div className='form'>
        <input type='text' className='input' />
        <textarea className='input-text'></textarea>
        <button className='send' accessKey='s'>Send</button>
      </div>
    </div>;
  }
})

var Notifications = React.createClass({
  getInitialState: function() {
    return {activeUsers:[], inactiveUsers: []};
  },
  loadUsers: function() {
    var n = this;
    $.getJSON("/notifications/unread.json", function(data, status, xhr) {
      var users = data.notifications;
      var active = [];
      var inactive = [];
      users.forEach(function(user, index) {
        if(!user) return;
        user.active = user.messages > 0 || user.mentions > 0;
        if(user.active) active.push(user);
        else inactive.push(user);
      });
      n.setState({activeUsers:active, inactiveUsers:inactive});
    });
  },
  render: function() {
    return <div className='notifications'>
      <NotificationUserList activeUsers={this.state.activeUsers} inactiveUsers={this.state.inactiveUsers} />

      <div className="messages">
        <div className="message-list">
        </div>
        <div className="empty">
          <div className="message">
            Write a message to <span className="username"></span>.
          </div>
        </div>
        <div className="welcome">
          <div className="message">
            Write a message to <span className="username"></span>.
          </div>
        </div>

        <NotificationResponse />
      </div>
    </div>;
  }
});

$(function() {
  var notifications =  $(".notifications");
  if(notifications.length > 0) {
    user_id = notifications.data("user-id");
    var n = React.render(<Notifications />, notifications.get(0));
    n.loadUsers();

    // desktop = function() {
    //   return window.matchMedia("screen and (min-width: 800px)").matches;
    // }
    // resize = function() {
    //   var height = ""
    //   if(desktop()) {
    //     var input_height = 0;
    //     if($(".input-text").hasClass("active")) {
    //       var input_height = parseInt($(".notifications .input-text").css("height")) - parseInt($(".notifications .input").css("height"));
    //     }
    //     var response_height = parseInt($(".notifications .response").css("height")) + 44 + input_height;
    //     var h = $(window).height() - $(".notifications").get(0).offsetTop - response_height - 30;
    //     var height = h + "px";
    //   }
    //
    //   $(".notifications .users").css("height", height)
    //   notifications.css("height", height)
    //   $(".notifications .empty").css("height", height)
    //   $(".notifications .welcome").css("height", height)
    // };
    // $(window).resize(resize);
  }
})
