var ChannelEvent = React.createClass({
  render: function() {
    var body = {__html: this.props.event.html_message};
    var userLink = "/users/"+this.props.user.id;
    var className = "event "+this.props.event.event;
    return <div className={className}>
      <span className="user">
        <a className="avatar" href={userLink}><img className="avatar-image" src={this.props.user.avatar_url} /></a>
        <span className="user-name">{this.props.user.login}</span>
      </span>
      <span className="message" dangerouslySetInnerHTML={body} />
    </div>;
  }
});

// module.exports = ChannelEvent;
window.ChannelEvent = ChannelEvent;
