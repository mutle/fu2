var Channel = React.createClass({
  render: function() {
    var className = "channel channel-"+this.props.channel.id;
    if(this.props.channel.read) className += " read";
    if(this.props.highlight) className += " highlight";
    var url = Data.url_root + "/channels/"+this.props.channel.id+"#post-"+this.props.channel.last_post_id;
    var displayName = this.props.channel.display_name;
    var channelName = {__html: displayName};
    return <li>
      <div className={className}>
        <div className="timestamp">
          <Timestamp timestamp={this.props.channel.display_date} />
        </div>
        <UserLink user={this.props.user} />
        <a className="channel-name" href={url} dangerouslySetInnerHTML={channelName}></a>
      </div>
    </li>;
  }
});

// module.exports = Channel;
window.Channel = Channel;
