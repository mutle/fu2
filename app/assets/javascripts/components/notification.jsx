// var React = require('react');

var Notification = React.createClass({
  timestampText: function() {
    return formatTimestamp(this.props.timestamp);
  },
  render: function() {
    console.log(this.props);
    var className = "" + (this.props.own ? "own" : "");
    var message = {__html: this.props.message};
    var ts = this.timestampText();
    return <div className="notification">
      <timestamp title={this.props.timestamp}>{ts}</timestamp>
      <message className={className}>
        <from className='user'>
          <img className="avatar" src={this.props.avatarUrl} />
          <span className="name">{this.props.name}</span>
        </from>
        <div className="body">
          <div className="content" dangerouslySetInnerHTML={message}></div>
        </div>
      </message>
    </div>;
  }
});

// module.exports = Notification;
window.Notification = Notification;
