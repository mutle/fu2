var NotificationCounter = React.createClass({
  getInitialState: function() {
    return {messages: 0, mentions: 0};
  },
  refresh: function(force) {
    var n = this;
    if(force || !this.socket) {
      $.getJSON("/notifications/counters.json", {}, function(data, status, xhr) {
        n.setState({messages: data.messages, mentions: data.mentions});
      });
      window.setTimeout(this.refresh, 12 * 1000);
    }
    if(!this.socket) {
      window.socket.subscribe("counters", function(data) {
        console.log(data);
        n.setState({messages: data.messages, mentions: data.mentions});
      });
      this.socket = true;
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
  var counters = $(".toolbar .counters");
  if(counters.length > 0) {
    var counter = React.render(<NotificationCounter />, counters.get(0));
    counter.refresh(true);
  }
});
