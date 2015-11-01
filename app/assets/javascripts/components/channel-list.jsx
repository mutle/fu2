// var React = require("react");
// var LoadingIndicator = require("./loading-indicator");

var ChannelListData = {
  url: "/api/channels.json",
  result: {
    channels: ["channel"]
  },
  view: "channel",
  subscribe: [
    "channel_update",
    "channel_create",
    "channel_read"
  ]
};

var Channel = React.createClass({
  render: function() {
    var className = "channel channel-"+this.props.channel.id;
    if(this.props.channel.read) className += " read";
    if(this.props.highlight) className += " highlight";
    var url = "/channels/"+this.props.channel.id+"#post-"+this.props.channel.last_post_id;
    var userLink = "/users/"+this.props.user.id;
    var userName = {__html: this.props.user.display_name};
    var channelName = {__html: this.props.channel.title};
    return <li>
      <div className={className}>
        <div className="timestamp">
          <Timestamp timestamp={this.props.channel.display_date} />
        </div>
        <a className="avatar" href={userLink}><img className="avatar-image" src={this.props.user.avatar_url} /></a>
        <span className="user-name" dangerouslySetInnerHTML={userName}></span>
        <a className="channel-name" href={url} dangerouslySetInnerHTML={channelName}></a>
      </div>
    </li>;
  }
});

var ChannelList = React.createClass({
  getInitialState: function() {
    return {channels: [], view: {}, highlight: -1};
  },
  componentDidMount: function() {
    var self = this;
    Data.subscribe("channel", this, 0, {callback: this.updated, fetch: this.fetchUpdatedChannels});
    Data.fetch(ChannelListData);
    this.keydownCallback = $(document).on("keydown", function(e) {
      if(!self.isMounted()) return;
      if(e.target != $("body").get(0)) return;
      if(e.ctrlKey || e.metaKey || e.shiftKey || e.altKey) return;
      var key = String.fromCharCode(e.keyCode);
      if(key == "J") {
        if(self.state.highlight+1 < self.state.channels.length)
          self.setState({highlight: self.state.highlight+1});
        else
          self.setState({highlight: 0});
        self.scrollToHighlight();
        e.preventDefault();
      }
      if(key == "K") {
        if(self.state.highlight > 0)
          self.setState({highlight: self.state.highlight-1});
        else
          self.setState({highlight: self.state.channels.length-1});
        self.scrollToHighlight();
        e.preventDefault();
      }
      if((key == "O" || e.keyCode == 13) && self.state.highlight >= 0) {
        Router.open("channels/show",{channel_id: self.state.channels[self.state.highlight].id}, true);
        e.preventDefault();
      }
    });
  },
  scrollToHighlight: function() {
    if(this.state.highlight >= 0) {
      var channel = this.state.channels[this.state.highlight];
      if(channel) {
        o = $(this.getDOMNode()).find(".channel-"+channel.id).offset();
        if(o) {
          $(window).scrollTop(o.top - 150);
        }
      }
    }
  },
  componentWillUnmount: function() {
    Data.unsubscribe(this);
    $(document).off("keydown", this.keydownCallback);
  },
  updated: function(objects, view) {
    var sorted = objects.sort(function(a,b) { return b.display_date - a.display_date; });
    highlight = this.state.highlight;
    if(highlight == -1) {
      for(var c in sorted) {
        var chan = sorted[c];
        if(!chan.read) {
          highlight = c;
          break;
        }
      }
    }
    this.setState({channels: sorted, view: view, highlight: highlight});
  },
  loadMore: function(e) {
    Data.fetch(ChannelListData, 0, {page: this.state.view.page + 1});
    e.preventDefault();
  },
  fetchUpdatedChannels: function() {
    // Data.fetch(ChannelListData, 0, {last: true});
  },
  render: function() {
    if(this.state.channels.length < 1) return <LoadingIndicator />;
    var highlightId = this.state.highlight;
    var channels = this.state.channels.map(function(channel, i) {
      var user = Data.get("user", channel.last_post_user_id);
      var highlight = (i == highlightId);
      return <Channel key={channel.id} id={channel.id} user={user} channel={channel} highlight={highlight} />;
    });
    return <div>
      <ul className="channel-list refresh">
        {channels}
      </ul>
      <ViewLoader callback={this.loadMore} visible={this.state.channels.length} octicon="chevron-down" count={this.state.view.count} message={"older channels"} />
    </div>;
  }
});

// module.exports = ChannelList;
window.ChannelList = ChannelList;
