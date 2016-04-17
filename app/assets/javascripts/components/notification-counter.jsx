// var React = require('react');

var NotificationCounter = React.createClass({
  getInitialState: function() {
    return {messages: 0, mentions: 0};
  },
  connect: function() {
    var n = this;
    this.socket = false;
    window.socket.subscribe(["counters", "offline_counters"], function(data, type) {
      n.setState({messages: data.messages, mentions: data.mentions});
    }, function(e) {
      if(e != "counters") return;
      n.socket = true;
      n.refresh(true);
    }, function() {
      n.socket = false;
      n.refresh();
    });
    // this.refresh(true);
  },
  refresh: function(force) {
    var n = this;
    if(force || !this.socket) {
      console.log("update notifications");
      $.getJSON(Data.url_root+Data.url.notification.counters(), {}, function(data, status, xhr) {
        n.setState({messages: data.messages, mentions: data.mentions});
      });
    }
  },
  togglePopup: function(e) {
    var n = $(".notifications-container .notifications")
    if(n.length > 0 && !this.notification_list) {
      this.notification_list = ReactDOM.render(<NotificationList count={6} />, n.get(0));
    }
    n.toggle();
    e.preventDefault();
  },
  render: function() {
    var count = this.state.messages + this.state.mentions;
    if(count < 1) return null;
    var className = "count";
    if(this.state.messages == 0) className += " mentions";
    return <span className={className}><a href="#" onClick={this.togglePopup}>{count}</a></span>;
  }
})

$(function() {
  var counters = $(".header .counters");
  if(counters.length > 0) {
    var counter = ReactDOM.render(<NotificationCounter />, counters.get(0));
    counter.connect();
  }
});

// module.exports = NotificationCounter;
window.NotificationCounter = NotificationCounter;
