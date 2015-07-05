var ChannelListData = {
  url: "/channels",
  result: {
    channels: ["channel"]
  },
  subscribe: [
    "channel_update",
    "channel_create",
    "post_read"
  ]
};

var Channel = React.createClass({
  render: function() {
    var className = "channel";
    if(this.props.channel.read) className += " read";
    var url = "/channels/"+this.props.channel.id;
    var userLink = "/users/"+this.props.user.id;
    var userName = {__html: this.props.user.display_name}
    var channelName = {__html: this.props.channel.title}
    return <div>
      <div className={className}>
        <a className="avatar" href={userLink}><img className="avatar-image" src={this.props.user.avatar_url} /></a>
        <span className="user-name" dangerouslySetInnerHTML={userName}></span>
        <a className="channel-name" href={url} dangerouslySetInnerHTML={channelName}></a>
      </div>
      <div className="timestamp">
        <Timestamp timestamp={this.props.channel.display_date} />
      </div>
    </div>;
  }
});

var ChannelList = React.createClass({
  getInitialState: function() {
    return {channels: []};
  },
  componentDidMount: function() {
    console.log(this.props.channelId);
    Data.subscribe("channel", this.updated, this);
    Data.fetch(ChannelListData);
  },
  updated: function(objects) {
    console.log("channel list updated");
    objects = objects.sort(function(a,b) { b.display_date - a.display_date });
    console.log(objects);
    this.setState({channels: objects});
  },
  render: function () {
    var channels = this.state.channels.map(function(channel, i) {
      var user = Data.get("user", channel.last_post_user_id);
      return <Channel key={channel.id} id={channel.id} user={user} channel={channel} />;
    });
    return <div>
      {channels}
    </div>;
  }
});

$(function() {
  var e = $(".channel-list.refresh");
  if(e.length > 0) {
    var posts = React.render(<ChannelList />, e.get(0))
  }

  var timestamps = []
  window.updateTimestamps = function(timestampE) {
    $.each(timestampE, function(i,e) {
     var t = parseInt($(e).data("timestamp")) * 1000;
     var ts = React.render(<Timestamp timestamp={t} />, e);
     timestamps.push(ts);
   });
  }
  var updateTs = function() {
    $.each(timestamps, function(i, ts) {
      ts.setState({});
    });
  }
  window.setInterval(updateTs, 1000);
  updateTimestamps($(".update-ts"));
});
