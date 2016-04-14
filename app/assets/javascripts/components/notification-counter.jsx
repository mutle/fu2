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
    }, function() {
      n.socket = true;
      n.refresh(true);
    }, function() {
      n.socket = false;
      n.refresh();
    });
    this.refresh(true);
  },
  refresh: function(force) {
    var n = this;
    if(force || !this.socket) {
      $.getJSON(Data.url_root+Data.url.notification.counters(), {}, function(data, status, xhr) {
        n.setState({messages: data.messages, mentions: data.mentions});
      });
    }
  },
  render: function() {
    var messageCounter = this.state.messages > 0 ? <div className="count"><a href="/notifications">{this.state.messages}</a></div> : null;
    var mentionCounter = this.state.mentions > 0 ? <div className="count mentions"><a href="/notifications">{this.state.mentions}</a></div> : null;
    return <div>
      {messageCounter}
      {mentionCounter}
    </div>
  }
})

$(function() {
  var counters = $(".header .counters .counters-inner");
  if(counters.length > 0) {
    var counter = ReactDOM.render(<NotificationCounter />, counters.get(0));
    counter.connect();
  }
});

// module.exports = NotificationCounter;
window.NotificationCounter = NotificationCounter;
