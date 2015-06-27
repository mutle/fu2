var user_id = 0;
var notifications;
var notificationsE;
var month_names = ["January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December"];
var this_year = (new Date()).getFullYear();

var scrollMessages = function() {
  var messages = $(".messages .message-list");
  if(messages.length > 0) {
    messages.scrollTop(messages[0].scrollHeight);
  }
};

var inputValue = function() {
  if($(".input-text").hasClass("active"))
    return $(".input-text").val();
  else
    return $(".input").val();
};

var desktop = function() {
  return window.matchMedia("screen and (min-width: 800px)").matches;
};

var resize = function() {
  var height = "";
  if(desktop()) {
    var input_height = 0;
    if($(".input-text").hasClass("active")) {
      input_height = parseInt($(".notifications .input-text").css("height")) - parseInt($(".notifications .input").css("height"));
    }
    var response_height = parseInt($(".notifications .response").css("height")) + 44 + input_height;
    var h = $(window).height() - $(".notifications").get(0).offsetTop - response_height - 30;
    height = h + "px";
  }

  $(".notifications .users").css("height", height);
  messages = $(".messages .message-list");
  messages.css("height", height);
  $(".notifications .empty").css("height", height);
  $(".notifications .welcome").css("height", height);

  if(desktop()) scrollMessages();
};

var resetInput = function() {
  $(".input-text").val("").removeClass("active")
  $(".messages .response .input").val("").show()
  resize()
};

var NotificationUser = React.createClass({
  click: function(e) {
    notifications.show(this.props.id);
  },
  render: function() {
    var showMessageClass = "indicator message" + (this.props.countMessages > 0 ? " show" : "");
    var showMentionClass = "indicator mention" + (this.props.countMentions > 0 ? " show" : "");
    var className = "user" + (this.props.active ? " active" : "");
    return <li className={className} onClick={this.click}>
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
    return <ul className='users'>
      <li className="divider divider-top">Conversations</li>
      {this.props.activeUsers.map(showUser)}
      <li className="divider">No history yet</li>
      {this.props.inactiveUsers.map(showUser)}
    </ul>;
  }
});

var Notification = React.createClass({
  timestampText: function() {
    var d = new Date(this.props.timestamp);
    var today = new Date();
    var minutes = Math.round(d.getMinutes() / 5.0) * 5;
    if(minutes < 10)
      minutes = "0"+minutes;
    var year = d.getFullYear() != this_year ? " "+d.getFullYear() : "";
    var date = today.getFullYear() == d.getFullYear() && today.getMonth() == d.getMonth() && today.getDate() == d.getDate() ? "" : month_names[d.getMonth()]+" "+d.getDate()+""+year+" - ";
    return date+""+d.getHours()+":"+minutes;
  },
  render: function() {
    var className = "" + (this.props.own ? "own" : "");
    var message = {__html: this.props.message};
    var ts = this.timestampText();
    return <div>
      <timestamp>{ts}</timestamp>
      <message className={className}>
        <from className='user'>
        </from>
        <div className="body">
          <div className="content" dangerouslySetInnerHTML={message}></div>
        </div>
      </message>
    </div>;
  }
});

var NotificationView = React.createClass({
  render: function() {
    var showNotification = function(notification, index) {
      var displayId = (notification.notification_type == "response" ? notification.user_id : notification.created_by_id);
      var own = displayId == user_id;
      return <Notification key={notification.id} message={notification.message} own={own} timestamp={notification.created_at} />;
    };
    if(!this.props.notifications)
      return <div className="welcome"><div className="message">Write a message to <span className="username"></span>.</div></div>;
    if(this.props.notifications.length == 0)
      return <div className="empty"><div className="message">Write a message to <span className="username"></span>.</div></div>;

    var className = "message-list" + (this.props.notifications.length > 0 ? " show" : "");
    return <div className={className}>
      {this.props.notifications.map(showNotification)}
    </div>;
  }
});

var NotificationResponse = React.createClass({
  submit: function(e) {
    e.preventDefault();
    if(!this.props.showUser) return;
    var message = inputValue();
    $.post("/notifications.json", {user_id: notifications.state.selectedUser, message: message}, function(data, status, xhr) {
      var n = notifications.state.notifications;
      n.push(data);
      notifications.setState({notifications:n, lastId: data.id+1});
      resetInput();
    });
  },
  render: function() {
    return <div className='response'>
      <form className='form' onSubmit={this.submit}>
        <input type='text' className='input' />
        <textarea className='input-text'></textarea>
        <button className='send' accessKey='s'>Send</button>
      </form>
    </div>;
  }
})

var Notifications = React.createClass({
  getInitialState: function() {
    return {activeUsers:[], inactiveUsers: [], selectedUser: 0, lastId: 0, notifications: null};
  },
  loadUsers: function() {
    var n = this;
    $.getJSON("/notifications/unread.json", function(data, status, xhr) {
      var users = data.notifications;
      var active = [];
      var inactive = [];
      users.forEach(function(user, index) {
        if(!user) return;
        user.active = user.messages != null || user.mentions != null;
        if(user.active) active.push(user);
        else inactive.push(user);
      });
      n.setState({activeUsers:active, inactiveUsers:inactive});
    });
  },
  show: function(user_id) {
    var n = this;
    $.getJSON("/notifications/"+user_id+".json", function(data, status, xhr) {
      var id = 0;
      for(var i in data.notifications) {
        var notification = data.notifications[i];
        if(notification.id > id) id = notification.id;
      }
      $.ajax({
        dataType: "json",
        type: "POST",
        url: "/notifications/"+user_id+"/read.json",
        success: function(data) {
          for(var index in n.state.activeUsers) {
            var user = n.state.activeUsers[index];
            if(user.id == user_id) {
              user.notifications = 0;
              user.mentions = 0;
              n.setState({activeUsers:n.state.activeUsers});
              break;
            }
          }
        }
      });
      n.setState({selectedUser: user_id, notifications:data.notifications, lastId: id});
    });
  },
  refresh: function() {
    if(this.state.selectedUser > 0) {
      var n = this;
      $.getJSON("/notifications/"+this.state.selectedUser+".json?last_id="+this.state.lastId, function(data, status, xhr) {
        var notifications = n.state.notifications;
        if(data.notifications.length > 0) {
          var id = n.state.lastId;
          console.log(data.notifications);
          for(var i in data.notifications) {
            var notification = data.notifications[i];
            if(notification.id > id) id = notification.id;
            notifications.push(notification);
          }
          console.log(id);
          n.setState({notifications:notifications, lastId: id});
        }
      });
    }
    window.setTimeout(this.refresh, 5 * 1000);
  },
  componentDidUpdate: function() {
    scrollMessages();
  },
  render: function() {
    return <div>
      <NotificationUserList activeUsers={this.state.activeUsers} inactiveUsers={this.state.inactiveUsers} />

      <div className="messages">
        <NotificationView notifications={this.state.notifications} />
        <NotificationResponse showUser={this.state.selectedUser != 0} />
      </div>
    </div>;
  }
});

$(function() {
  notificationsE =  $(".notifications");
  if(notificationsE.length > 0) {
    user_id = notificationsE.data("user-id");
    notifications = React.render(<Notifications />, notificationsE.get(0));
    notifications.loadUsers();
    $(window).resize(resize);
    notifications.refresh();
    resize();
  }
})
