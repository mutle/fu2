// var React = require("react");
// var LoadingIndicator = require("./loading-indicator");

var ChannelListData = {
  url: "/api/channels.json",
  result: {
    channels: ["channel"]
  },
  subscribe: [
    "channel_update",
    "channel_create",
    "channel_read"
  ]
};

var Channel = React.createClass({
  click: function(e) {
    e.preventDefault();
    Router.open("channels/show", {channel_id: this.props.channel.id}, true);
  },
  render: function() {
    var className = "channel";
    if(this.props.channel.read) className += " read";
    var url = "/channels/"+this.props.channel.id+"#post-"+this.props.channel.last_post_id;
    var userLink = "/users/"+this.props.user.id;
    var userName = {__html: this.props.user.display_name};
    var channelName = {__html: this.props.channel.title};
    return <li>
      <div className={className}>
        <a className="avatar" href={userLink}><img className="avatar-image" src={this.props.user.avatar_url} /></a>
        <span className="user-name" dangerouslySetInnerHTML={userName}></span>
        <a className="channel-name" onClick={this.click} href={url} dangerouslySetInnerHTML={channelName}></a>
      </div>
      <div className="timestamp">
        <Timestamp timestamp={this.props.channel.display_date} />
      </div>
    </li>;
  }
});

var ChannelList = React.createClass({
  getInitialState: function() {
    return {channels: []};
  },
  componentDidMount: function() {
    Data.subscribe("channel", this.updated, this);
    Data.fetch(ChannelListData);
  },
  updated: function(objects) {
    var sorted = objects.sort(function(a,b) { return b.display_date - a.display_date; });
    this.setState({channels: sorted});
  },
  render: function() {
    if(this.state.channels.length < 1) return <LoadingIndicator />;
    var channels = this.state.channels.map(function(channel, i) {
      var user = Data.get("user", channel.last_post_user_id);
      return <Channel key={channel.id} id={channel.id} user={user} channel={channel} />;
    });
    return <ul className="channel-list refresh">
      {channels}
    </ul>;
  }
});

// module.exports = ChannelList;
window.ChannelList = ChannelList;
