var ChannelPostsHeader = React.createClass({
  getInitialState: function() {
    return {edit: false};
  },
  toggleEdit: function(e) {
    e.preventDefault();
    console.log("edit");
    this.setState({edit: !this.state.edit});
  },
  save: function(e) {
    e.preventDefault();
    var self = this;
    if(this.props.channelId == 0) {
      var data = {body: $(".channel-text .body textarea").val(), title: $(".channel-title input.channel-title").val() };
      Data.action("create", "channel", [], data, {error: function() {
        console.log("Failed to create channel...");
      }, success: function(data) {
        Data.insert(data.channel);
        Data.notify([data.channel.type]);
        Router.open("channels/show", {channel_id: data.channel.id}, true);
      }});
    } else {
      var data = {text: $(".channel-text .body textarea").val(), title: $(".channel-title input.channel-title").val() };
      Data.action("update", "channel", [this.props.channelId], data, {error: function() {
        console.log("Failed to update channel...");
      }, success: function(data) {
        Data.insert(data.channel);
        Data.notify([data.channel.type]);
        self.setState({edit: false});
        self.props.channelPosts.setState({channel: data.channel});
      }});
    }
  },
  render: function() {
    var title = {__html: this.props.channel.display_name};
    if(this.state.edit || this.props.channelId == 0) {
      var className = "channel-" + (this.props.channelId > 0 ? "edit" : "new");
      var title = this.props.channelId > 0 ? "Save" : "Create"
      if(this.props.channelId > 0) var cancelLink = <a onClick={this.toggleEdit} className="cancel-edit-channel-link" href="#">Cancel</a>;
      return <div className={className}>
        <h2 className="channel-title">
          <div className="right">
            <button className="content-button button-default" onClick={this.save}>{title}</button>
            {cancelLink}
          </div>
          <input className="channel-title" placeholder="Channel Title" defaultValue={this.props.channel.title} />
        </h2>
        <div className="channel-text">
          <div className="body">
            <Editor textareaClass="text-box" initialText={this.props.channel.text} />
          </div>
        </div>
      </div>;
    } else {
      var body = {__html: this.props.channel.display_text};
      if(this.props.channel.last_text_change) {
        var user = Data.get("user", this.props.channel.last_text_change.user_id);
        var update_info = <span>
          <img className="avatar-image" src={user.avatar_url} />
          <Timestamp timestamp={this.props.channel.last_text_change.updated_at} />
        </span>;
      }
      var channelText = <div className="channel-text">
        <div className="body text-body" dangerouslySetInnerHTML={body} />
      </div>;

      return <div>
        <h2 className="channel-title">
          <div className="right">
            {update_info} <a onClick={this.toggleEdit} className="edit-channel-link" href="#">Edit</a>
          </div>
          <span className="title-text" dangerouslySetInnerHTML={title} />
        </h2>
        {channelText}
      </div>;
    }
  }
});

// module.exports = ChannelPostsHeader;
window.ChannelPostsHeader = ChannelPostsHeader;
