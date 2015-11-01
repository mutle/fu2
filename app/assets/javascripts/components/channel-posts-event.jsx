var ChannelEvent = React.createClass({
  getInitialState: function() {
    return {details: false};
  },
  toggleDetails: function(e) {
    e.preventDefault();
    this.setState({details: !this.state.details});
  },
  quoteOldText: function(e) {
    e.preventDefault();
    $(".comment-box-form textarea").val(ChannelPosts.quote(this.props.event.data.old_text)).select();
  },
  quoteText: function(e) {
    e.preventDefault();
    $(".comment-box-form textarea").val(ChannelPosts.quote(this.props.event.data.text)).select();
  },
  render: function() {
    console.log(this.props.event);
    var body = {__html: this.props.event.html_message};
    var userLink = "/users/"+this.props.user.id;
    var className = "event "+this.props.event.event;
    if(this.props.event.event == "text") {
      if(this.state.details) {
        var oldBody = {__html: this.props.event.data.old_text_html};
        var newBody = {__html: this.props.event.data.text_html};
        var extraLink = <a onClick={this.toggleDetails} href="#">Hide Changes</a>;
        var extra = <div className="event-details">
          <div className="column">
            <h3>Before <span onClick={this.quoteOldText} className="octicon octicon-mail-reply" /></h3>
            <div dangerouslySetInnerHTML={oldBody} />
          </div>
          <div className="column">
            <h3>After <span onClick={this.quoteText} className="octicon octicon-mail-reply" /></h3>
            <div dangerouslySetInnerHTML={newBody} />
          </div>
          <div className="after" />
        </div>;
      } else
        var extraLink = <a onClick={this.toggleDetails} href="#">Show Changes</a>;
    }
    return <div className={className}>
      <span className="user">
        <a className="avatar" href={userLink}><img className="avatar-image" src={this.props.user.avatar_url} /></a>
        <span className="user-name">{this.props.user.login}</span>
      </span>
      <span className="message" dangerouslySetInnerHTML={body} />
      {extraLink}
      {extra}
    </div>;
  }
});

// module.exports = ChannelEvent;
window.ChannelEvent = ChannelEvent;
