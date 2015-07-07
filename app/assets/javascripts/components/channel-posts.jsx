// var React = require('react');
// var LoadingIndicator = require("./loading-indicator");

var ChannelPostsData = {
  url: "/api/channels/{id}/posts.json",
  result: {
    posts: ["post"],
    channel: "channel"
  },
  subscribe: [
    "post_create"
  ]
};

var FaveCounter = React.createClass({
  getInitialState: function() {
    return {state: 0};
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
    if(!this.props.faves || this.props.faves.length == 0) inner = <span>{icon}{'0'}</span>;
    else inner = <span>{icon}{this.props.faves.length}</span>;
    var className = "";
    if(this.props.faves.length > 0) className = "faved";
    if(this.state.state == 1) className = "on";
    return <a href="#" title={(this.props.faves ? this.props.faves : []).join(", ")} onClick={this.click} className={className}>{inner}</a>;
  }
});

var ChannelPostHeader = React.createClass({
  render: function() {
    var userLink = "/users/"+this.props.user.id;
    var postDeleteLink = <a className="post-delete" onClick={this.delete}><span className="octicon octicon-trashcan"></span></a>;
    var postEditLink = <a className="post-edit"><span className="octicon octicon-pencil"></span></a>;
    var postUnreadLink = <a className="post-unread"><span className="octicon octicon-eye"></span></a>;
    var postReplyLink = <a className="post-reply"><span className="octicon octicon-mail-reply"></span></a>;
    return <div className="channel-post-header">
      <a className="avatar" href={userLink}><img className="avatar-image" src={this.props.user.avatar_url} /></a>
      <span className="user-name">{this.props.user.login}</span>
      <div className="right">
        {postDeleteLink}
        {postEditLink}
        <FaveCounter faves={this.props.post.faves} postId={this.props.id}  />
        {postUnreadLink}
        {postReplyLink}
        <Timestamp timestamp={this.props.post.created_at} />
      </div>
    </div>;
  }
})

var ChannelPost = React.createClass({
  render: function() {
    var body = {__html: this.props.post.html_body};
    var className = "channel-post";
    if(this.props.post.read) className += " read";
    return <div className={className}>
      <ChannelPostHeader id={this.props.id} user={this.props.user} post={this.props.post} />
      <div className="body" dangerouslySetInnerHTML={body}></div>
    </div>;
  }
});

var ChannelPostsHeader = React.createClass({
  getInitialState: function() {
    return {edit: false};
  },
  toggleEdit: function() {
    this.setState({edit: !this.state.edit});
  },
  render: function() {
    var title = {__html: this.props.channel.display_name};
    if(this.state.edit) {
      return <div>
        <h2 className="channel-title">
          <div className="right">
            <button>Save</button>
            <a onClick={this.toggleEdit} className="cancel-edit-channel-link" href="#">Cancel</a>
          </div>
          <input className="channel-title" defaultValue={this.props.channel.title} />
        </h2>
        <div className="body">
          <textarea defaultValue={this.props.channel.text} />
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

var ChannelPosts = React.createClass({
  getInitialState: function() {
    return {posts: [], channel: {}};
  },
  componentDidMount: function() {
    console.log(this.props.channelId);
    Data.subscribe("post", this.updatedPosts, this, this.props.channelId);
    Data.subscribe("channel", this.updatedChannel, this);
    Data.fetch(ChannelPostsData, this.props.channelId);
  },
  updatedPosts: function(objects) {
    console.log("channel posts updated")
    console.log(objects)
    this.setState({posts: objects})
  },
  updatedChannel: function(objects) {
    console.log("channel updated")
    console.log(objects)
    if(objects.length > 0) this.setState({channel: objects[0]})
  },
  render: function () {
    if(this.state.posts.length < 1 || !this.state.channel.id) return <LoadingIndicator />;
    var posts = this.state.posts.map(function(post, i) {
      var user = Data.get("user", post.user_id);
      return <ChannelPost key={post.id} id={post.id} user={user} post={post} />;
    });
    return <div>
      <ChannelPostsHeader channel={this.state.channel} />
      {posts}
      <CommentBox channelId={this.props.channelId} />
    </div>;
  }
});

// module.exports = ChannelPosts;
window.ChannelPosts = ChannelPosts;
