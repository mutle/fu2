var ChannelTag = React.createClass({
  render: function() {
    return <div className="channel-tag">
      <h2>#{this.props.tag}</h2>
      <div className="tag-channel-list">
        <ChannelList tag={this.props.tag} />
      </div>
      <div className="clear"></div>

      <h3>Recent posts</h3>
      <div className="tag-channel-posts">
        <ChannelPosts tag={this.props.tag} hideHeader={true} />
      </div>
    </div>;
  }
});

// module.exports = ChannelTag;
window.ChannelTag = ChannelTag;
