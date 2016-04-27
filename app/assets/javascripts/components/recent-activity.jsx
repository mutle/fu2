var RecentActivityData = {
  url: "/api/channels/recent.json",
  view: "recent-activity",
  subscribe: [],
  storeResult: true
};


var RecentActivity = React.createClass({
  getInitialState: function() {
    return {activity: null, timeframe: "1w", menuActive: false};
  },
  componentDidMount: function() {
    Data.subscribe("recent-activity", this, 0, {callback: this.updatedData});
    Data.fetch(RecentActivityData, this.state.timeframe, {timeframe: this.state.timeframe});
  },
  componentWillUnmount: function() {
    Data.unsubscribe(this, RecentActivityData.subscribe);
  },
  updatedData: function(objects, view) {
    this.setState({activity: objects[0]});
  },
  sortUsers: function(users) {
    if(!this.state.activity) return users;
    var active_users = this.state.activity.active_users;
    return users.sort(function(a,b) { return (active_users[b.id] || 0) - (active_users[a.id] || 0); });
  },
  toggleMenu: function(e) {
    e.preventDefault();
    this.setState({menuActive: !this.state.menuActive});
  },
  updateTimeframe: function(e) {
    e.preventDefault();
    var self = this;
    this.setState({timeframe: $(e.target).data("value"), menuActive: false, activity: null}, function() {
      Data.fetch(RecentActivityData, this.state.timeframe, {timeframe: self.state.timeframe});
    });
  },
  render: function() {
    var activities = <LoadingIndicator />;
    if(this.state.activity) {
      var channels = this.state.activity.active_channels.map(function(c,i) {
        return <Channel key={c.id} id={c.id} channel={c} user={Data.get("user", c.last_post_user_id)} />;
      });
      var best_posts = this.state.activity.best_posts.map(function(post, i) {
        return <ChannelPost key={post.id} post={post} id={post.id} channelId={post.channel_id} user={Data.get("user", post.user_id)} />;
      });
      var users = [];
      for(var user in this.state.activity.active_users) {
        var i = this.state.activity.active_users[user];
        var us = Data.get("user", user);
        users.push(us);
      }
      var emojis = [];
      var active_emojis = [];
      for(var emoji in this.state.activity.active_emojis) {
        active_emojis.push(emoji);
      }
      var am = this.state.activity.active_emojis;
      var sorted_active_emojis = active_emojis.sort(function(a,b) { return (am[b] || 0) - (am[a] || 0); });
      for(var ei in sorted_active_emojis) {
        var emoji = sorted_active_emojis[ei];
        var i = this.state.activity.active_emojis[emoji];
        var em = window.Emojis.find(function(em,im) { return em.aliases[0] == emoji });
        var e = <span key={emoji} className="emoji-reaction"><img className="emoji" src={em.image} />{i}</span>;
        emojis.push(e);
      }
      activities = <div>
        <h3 className="activity-header">Active Channels</h3>
        <div className="channel-list-container">
          <ul className="channel-list refresh">
            {channels}
          </ul>
        </div>

        <h3 className="activity-header">Popular Posts</h3>
        {best_posts}

        <h3 className="activity-header">Active Users</h3>
        <UserList users={users} sort={this.sortUsers} info={this.state.activity.active_users} hideHeader={true} />

        <h3 className="activity-header">Reactions</h3>
        {emojis}
      </div>;
    }
    var menuClassName = "select-menu";
    if(this.state.menuActive) menuClassName += " active";
    var timeframes = {
      "1d": "24h",
      "3d": "3 days",
      "1w": "week",
      "1m": "month"
    }
    return <div className="recent-activity">
      <h2>Recent activity</h2>

      Show: <div className={menuClassName}>
        <div className="select-menu-options">
          <span data-value="1d" className={"option" + this.state.timeframe == "1d" ? " selected" : ""} onClick={this.updateTimeframe}>{"Last "+timeframes["1d"]}</span>
          <span data-value="3d" className={"option" + this.state.timeframe == "3d" ? " selected" : ""} onClick={this.updateTimeframe}>{"Last "+timeframes["3d"]}</span>
          <span data-value="1w" className={"option" + this.state.timeframe == "1w" ? " selected" : ""} onClick={this.updateTimeframe}>{"Last "+timeframes["1w"]}</span>
          <span data-value="1m" className={"option" + this.state.timeframe == "1m" ? " selected" : ""} onClick={this.updateTimeframe}>{"Last "+timeframes["1m"]}</span>
        </div>
        <span className="title" onClick={this.toggleMenu}>Last {timeframes[this.state.timeframe]}</span>
      </div>

      {activities}
    </div>;
  }
});

// module.exports = RecentActivity;
window.RecentActivity = RecentActivity;
