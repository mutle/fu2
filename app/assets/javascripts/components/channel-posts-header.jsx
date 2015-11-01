var ChannelPostsHeader = React.createClass({
  getInitialState: function() {
    return {edit: false};
  },
  toggleEdit: function(e) {
    e.preventDefault();
    this.setState({edit: !this.state.edit});
  },
  save: function() {
    if(this.props.channelId == 0) {
      var data = {body: $(".channel-text .body textarea").val(), title: $(".channel-title input.channel-title").val() };
      Data.action("create", "channel", [], data, {error: function() {
        console.log("Failed to create channel...");
      }, success: function(data) {
        Router.open("channels/show", {channel_id: data.channel.id}, true);
      }});
    }
  },
  render: function() {
    var title = {__html: this.props.channel.display_name};
    if(this.state.edit || this.props.channelId == 0) {
      var title = this.props.channelId > 0 ? "Save" : "Create"
      if(this.props.channelId > 0) var cancelLink = <a onClick={this.toggleEdit} className="cancel-edit-channel-link" href="#">Cancel</a>;
      return <div>
        <h2 className="channel-title">
          <div className="right">
            <button onClick={this.save}>{title}</button>
            {cancelLink}
          </div>
          <input className="channel-title" placeholder="Channel Title" defaultValue={this.props.channel.title} />
        </h2>
        <div className="channel-text">
          <div className="body">
            <textarea defaultValue={this.props.channel.text} />
          </div>
        </div>
      </div>;
    } else {
      var body = {__html: this.props.channel.display_text};
      if(this.props.channel.text) {
        var channelText = <div className="channel-text">
          <div className="body text-body" dangerouslySetInnerHTML={body} />
        </div>;
      }
      return <div>
        <h2 className="channel-title">
          <div className="right"><a onClick={this.toggleEdit} className="edit-channel-link" href="#">Edit</a></div>
          <span className="title-text" dangerouslySetInnerHTML={title} />
        </h2>
        {channelText}
      </div>;
    }
  }
});

// module.exports = ChannelPostsHeader;
window.ChannelPostsHeader = ChannelPostsHeader;
