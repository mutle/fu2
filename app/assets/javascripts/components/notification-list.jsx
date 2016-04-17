// var React = require('react');

var NotificationListData = {
  url: "/api/notifications.json",
  result: {
    notifications: ["notification"]
  },
  view: "notification",
  subscribe: [
    "notification_create"
  ]
};

var NotificationActivity = React.createClass({
  render: function() {
    var n = this.props.notification;
    if(!n) return null;
    var url, message;
    var className = "notification-activity";
    var userInfo = <span>
      <img className="avatar" src={this.props.user.avatar_url} />
      {this.props.user.login}
      <span className="timestamp"><Timestamp timestamp={n.created_at} /></span>
    </span>;
    if(n.notification_type == "mention") {
      url = "/channels/"+n.channel_id+"#post-"+n.post_id;
      var body = {__html: n.post.html_body};
      message = <span>
        {userInfo} mentioned you in <a href={url}>{n.channel.title}</a>
        <span className="body" dangerouslySetInnerHTML={body} />
      </span>;
    } else {
      url = "/notifications/"+n.created_by_id;
      var body = {__html: n.message};
      message = <span>
        {userInfo}
        <span className="body" dangerouslySetInnerHTML={body} />
      </span>;
    }
    if(n.read) className += " read";
    return <div className={className}>
      <a className="notification-link" href={url}></a>
      {message}
    </div>;
  }
});

var NotificationList = React.createClass({
  getInitialState: function() {
    return {notifications: null, view: null};
  },
  componentDidMount: function() {
    Data.subscribe("notification", this, 0, {callback: this.updated});
    Data.fetch(NotificationListData, 0, {per_page: this.perPage()}, this.fetchUpdatedNotifications);
  },
  fetchUpdatedNotifications: function() {
    if(this.state.view) {
      Data.fetch(NotificationListData, 0, {per_page: this.perPage(), last_update: this.state.view.last_update + 1});
    }
  },
  perPage: function() {
    if(this.props.count) return this.props.count;
    return 25;
  },
  updated: function(objects, view) {
    console.log([objects, view]);
    var sorted = objects.sort(function(a,b) { return new Date(b.created_at) - new Date(a.created_at); });
    this.setState({notifications: sorted, view: view});
  },
  loadMore: function(e) {
    Data.fetch(NotificationListData, 0, {per_page: this.perPage(), page: this.state.view.page + 1});
    e.preventDefault();
  },
  componentWillUnmount: function() {
    Data.unsubscribe(this, NotificationListData.subscribe);
  },
  render: function() {
    if(!this.state.notifications) return <LoadingIndicator />;
    var notifications = this.state.notifications.map(function(n, i) {
      var user = Data.get("user", n.created_by_id);
      if(n.notification_type == "response") return null;
      return <NotificationActivity key={n.id} notification={n} user={user} />;
    });
    return <div className="notification-list">
      {notifications}
      <ViewLoader callback={this.loadMore} visible={this.state.notifications.length} octicon="chevron-down" count={this.state.view.count} message={"older notifications"} />
    </div>
  }
});

// module.exports = NotificationList;
window.NotificationList = NotificationList;
