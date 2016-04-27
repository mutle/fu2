var UserStatsData = {
  url: "/api/users/{id}/stats.json",
  view: "user-$ID-stats",
  subscribe: [],
  storeResult: true
};

var UserProfile = React.createClass({
  getInitialState: function() {
    return {stats: null};
  },
  componentWillMount: function() {
    var user = Data.get("user", parseInt(this.props.userId));
    if(user) {
      this.user = user;
    } else {
      for(var u in window.Users) {
        user = window.Users[u];
        if(user.login.toLowerCase() == this.props.userId.toLowerCase()) {
          this.user = user;
          break;
        }
      }
    }
  },
  componentDidMount: function() {
    if(this.user) {
      Data.subscribe("user-"+this.user.id+"-stats", this, 0, {callback: this.updatedUser});
      Data.fetch(UserStatsData, this.user.id);
    }
  },
  componentWillUnmount: function() {
    Data.unsubscribe(this, UserStatsData.subscribe);
  },
  updatedUser: function(objects, view) {
    this.setState({stats: objects[0]});
  },
  renderRecents: function() {
    if(this.props.small) return null;
    var last_posts = this.state.stats.last_posts.map(function(post, i) {
      return <ChannelPost key={post.id} post={post} id={post.id} channelId={post.channel_id} user={Data.get("user", post.user_id)} />;
    });
    var last_faves = this.state.stats.last_faves.map(function(post, i) {
      return <ChannelPost key={post.id} post={post} id={post.id} channelId={post.channel_id} user={Data.get("user", post.user_id)} />;
    });
    return <div>
      <div className="user-posts">
        <h3>Last posts</h3>
        {last_posts}
      </div>

      <div className="user-reactions">
        <h3>Last reactions</h3>
        {last_faves}
      </div>
    </div>;
  },
  renderUserInfo: function() {
    if(this.props.small) {
      // <p>Last active: <span className="stat"><Timestamp timestamp={this.state.stats.last_active * 1000} /></span></p>
      return <div className="user-info">
      </div>;
    }
    var sorted = [];
    for(var emoji in this.state.stats.emojis) {
      var count = this.state.stats.emojis[emoji];
      var e = window.Emojis.find(function(em,im) { return em.aliases[0] == emoji });
      if(e) {
        sorted.push([count, emoji, e]);
      }
    }
    sorted = sorted.sort(function(a,b) { return b[0] - a[0]; });
    var emojis = [];
    for(var i in sorted) {
      var emoji = sorted[i];
      var e = <span className="emoji-reaction"><img className="emoji" src={emoji[2].image} />{emoji[0]}</span>;
      emojis.push(e);
    }
    return <div className="user-info">
      <h3>Stats</h3>
      <p>Joined: <span className="stat"><Timestamp timestamp={this.user.created_at} /></span></p>
      <p>Posts: <span className="stat">{this.state.stats.posts_count}</span></p>
      <p>Channels: <span className="stat">{this.state.stats.channels_count}</span></p>

      <h3>Reactions</h3>
      <p>Given: <span className="stat">{this.state.stats.faves_count}</span></p>
      <p>Received: <span className="stat">{this.state.stats.faves_received}</span></p>
      <p>Favorites:<br />{emojis}</p>
    </div>
  },
  render: function() {
    if(this.user) {
      var profile = <LoadingIndicator />;
      if(this.state.stats) {
        var profile = <div>
          {this.renderUserInfo()}
          {this.renderRecents()}
        </div>;
        if(this.state.stats.title && this.state.stats.title.length > 0) {
          var n = Math.floor(Math.random() * this.state.stats.title.length);
          var title = this.state.stats.title[n].split(":", 2);
          var user_title = <span> {title[1]} <UserLink user={Data.get("user", parseInt(title[0]))}/></span>;
        }
      }
      var name = {__html: this.user.display_name_html.replace(/<\/?p>/g, '')};
      var className = "user-profile";
      if(this.props.small) {
        className += " small";
      } else {
        var show_user_title = <div className="user-title">{user_title}</div>;
      }
      return <div className={className}>
        <h2 className="title">
          <img className="avatar-image" src={this.user.avatar_url_full} /> <span dangerouslySetInnerHTML={name} />
          {show_user_title}
        </h2>
        {profile}
      </div>;
    } else {
      var message = "User "+this.props.userId+" not found"
      return <ErrorMessage title={message} />;
    }
  }
});

// module.exports = UserProfile;
window.UserProfile = UserProfile;
