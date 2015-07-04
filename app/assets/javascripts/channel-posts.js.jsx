var Timestamp = React.createClass({
  shouldComponentUpdate: function() {
    if(!this.lastts) return true;
    if(this.lastts != formatTimestamp(this.props.timestamp)) return true;
    return false;
  },
  render: function() {
    console.log(this.props.timestamp)
    if(this.props.timestamp == "") return null;
    this.lastts = formatTimestamp(this.props.timestamp)
    return <span className="ts">{this.lastts}</span>;
  }
});

var FaveCounter = React.createClass({
  getInitialState: function() {
    return {faves: [], state: 0};
  },
  click: function(e) {
    e.preventDefault();
    if(this.state.postId > 0) {
      var c = this;
      $.ajax({url:"/posts/"+this.props.postId+"/fave", dataType: "json", type: "post"}).done(function(msg) {
        c.setState({state: msg.status ? 1 : 0, faves: msg.faves});
      });
    }
  },
  render: function() {
    var icon = <span className="octicon octicon-star" />;
    var inner = null;
    if(!this.state.faves || this.state.faves.length == 0) inner = <span>{icon}{'0'}</span>;
    else inner = <span>{icon}{this.state.faves.length}</span>;
    var className = "";
    if(this.state.state == 1) className = "on";
    return <a href="#" title={(this.state.faves ? this.state.faves : []).join(", ")} onClick={this.click} className={className}>{inner}</a>;
  }
});

var ChannelPostHeader = React.createClass({
  render: function() {
    console.log(this.props.user)
    var userLink = "/users/"+this.props.user.id;
    return <div className="channel-post-header">
      <a className="avatar" href={userLink}><img className="avatar-image" src={this.props.user.avatar_url} /></a>
      <span className="user-name">{this.props.user.login}</span>
      <div className="right">
        <FaveCounter postId={this.props.id}  />
        <Timestamp timestamp={this.props.createdAt} />
      </div>
    </div>;
  }
})

var ChannelPost = React.createClass({
  render: function() {
    var body = {__html: this.props.body}
    return <div className="channel-post">
      <ChannelPostHeader id={this.props.id} user={this.props.user} createdAt={this.props.createdAt} />
      <div className="body" dangerouslySetInnerHTML={body}></div>
    </div>;
  }
});

var ChannelPosts = React.createClass({
  getInitialState: function() {
    return {posts: []};
  },
  componentDidMount: function() {
    console.log(this.props.channelId);
    Data.subscribe("channel_posts", this.updated, this, {}, this.props.channelId);
    Data.fetch("channel_posts", this.props.channelId);
  },
  updated: function(objects) {
    console.log("channel posts updated")
    console.log(objects)
    this.setState({posts: objects.map(function(object, i) { return object[2]; })})
  },
  render: function () {
    var posts = this.state.posts.map(function(post, i) {
      var user = Data.get("user", post.user_id);
      return <ChannelPost key={post.id} id={post.id} user={user} body={post.html_body} rawBody={post.body} createdAt={post.created_at} />;
    });
    return <div>
      {posts}
    </div>;
  }
});

$(function() {
  var e = $(".channel-posts.loader-group");
  if(e.length > 0) {
    var channel_id = parseInt(document.location.href.replace(/#.*$/, '').replace(/^.*\/([0-9]+)$/, "$1"))
    var posts = React.render(<ChannelPosts channelId={channel_id} />, e.get(0))
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
