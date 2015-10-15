// var React = require('react');
// var LoadingIndicator = require("./loading-indicator");

var ChannelPostsData = {
  url: "/api/channels/{id}/posts.json",
  result: {
    posts: ["post"],
    channel: "channel"
  },
  view: "post",
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
    if(this.props.postId > 0) {
      var c = this;
      $.ajax({url:"/api/posts/"+this.props.postId+"/fave", dataType: "json", type: "post"}).done(function(data) {
        console.log(data)
        Data.update("post", c.props.postId, data.post);
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
  edit: function() {
    this.props.channelPost.setState({edit: true});
  },
  render: function() {
    var userLink = "/users/"+this.props.user.id;
    var postLink = "/channels/"+this.props.channelId+"#post-"+this.props.id;
    var canEdit = false;
    var postDeleteLink = canEdit ? <a className="post-delete" onClick={this.delete}><span className="octicon octicon-trashcan"></span></a> : null;
    var postEditLink = canEdit ? <a className="post-edit" onClick={this.edit}><span className="octicon octicon-pencil"></span></a> : null;
    var postUnreadLink = <a className="post-unread"><span className="octicon octicon-eye"></span></a>;
    var postReplyLink = <a className="post-reply"><span className="octicon octicon-mail-reply"></span></a>;
    var favers = [];
    for(var i in this.props.post.faves) {
      var fave = this.props.post.faves[i];
      favers.push(Data.get("user", fave.user_id).login);
    }
    return <div className="channel-post-header">
      <a className="avatar" href={userLink}><img className="avatar-image" src={this.props.user.avatar_url} /></a>
      <span className="user-name">{this.props.user.login}</span>
      <div className="right">
        {postDeleteLink}
        {postEditLink}
        <FaveCounter faves={favers} postId={this.props.id}  />
        {postUnreadLink}
        {postReplyLink}
        <a href={postLink} className="timestamp">
          <Timestamp timestamp={this.props.post.created_at} />
        </a>
      </div>
    </div>;
  }
})

var ChannelPost = React.createClass({
  getInitialState: function() {
    return {edit: false};
  },
  render: function() {
    var body = {__html: this.props.post.html_body};
    var className = "channel-post post-"+this.props.post.id;
    if(this.props.post.read) className += " read";
    if(this.props.highlight) className += " highlight";
    if(this.state.edit)
      var content = <div class="channel-response channel-edit"><CommentBox postId={this.props.id} channelId={this.props.channelId} /></div>;
    else
      var content = <div className="body" dangerouslySetInnerHTML={body}></div>;
    return <div className={className}>
      <ChannelPostHeader id={this.props.id} channelId={this.props.channelId} user={this.props.user} post={this.props.post} channelPost={this} />
      {content}
    </div>;
  }
});

var ChannelPostsHeader = React.createClass({
  getInitialState: function() {
    return {edit: false};
  },
  toggleEdit: function(e) {
    e.preventDefault();
    this.setState({edit: !this.state.edit});
  },
  render: function() {
    var title = {__html: this.props.channel.display_name};
    if(this.state.edit || this.props.channelId == 0) {
      var title = this.props.channelId > 0 ? "Save" : "Create"
      if(this.props.channelId > 0) var cancelLink = <a onClick={this.toggleEdit} className="cancel-edit-channel-link" href="#">Cancel</a>;
      return <div>
        <h2 className="channel-title">
          <div className="right">
            <button>{title}</button>
            {cancelLink}
          </div>
          <input className="channel-title" placeholder="Channel Title" defaultValue={this.props.channel.title} />
        </h2>
        <div className="channel-text">
          <div className="body">
            <textarea defaultValue={this.props.channel.text} />
          </div>
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
    return {posts: [], channel: {}, view: {}, anchor: "", highlight: -1};
  },
  componentDidMount: function() {
    if(this.props.channelId > 0) {
      console.log(this.props.channelId);
      Data.subscribe("post", this, 0, {callback: this.updatedPosts, fetch: this.fetchUpdatedPosts});
      Data.subscribe("channel", this, this.props.channelId, {callback: this.updatedChannel});
      Data.fetch(ChannelPostsData, this.props.channelId);
    }

    var self = this;
    this.keydownCallback = $(document).on("keydown", function(e) {
      var key = String.fromCharCode(e.keyCode);
      if(key == "J") {
        if(self.state.highlight+1 < self.state.posts.length)
          self.setState({highlight: self.state.highlight+1});
        else
          self.setState({highlight: 0});
      }
      if(key == "K") {
        if(self.state.highlight > 0)
          self.setState({highlight: self.state.highlight-1});
        else
          self.setState({highlight: self.state.posts.length-1});
      }
    });
  },
  componentWillUnmount: function() {
    Data.unsubscribe(this);
    $(document).off("keydown", this.keydownCallback);
  },
  selectPost: function(post) {
    var h = "post-"+this.state.posts[0].id;
    this.setState({anchor: h});
    document.location.hash = h;
    console.log($(this.getDOMNode()).find(".post-"+post.id).offset().top)
    $(window).scrollTop($(this.getDOMNode()).find(".post-"+post.id).offset().top)
  },
  updatedPosts: function(objects, view) {
    highlight = this.state.highlight;
    if(highlight == -1) {
      for(var p in objects) {
        var post = objects[p];
        if((this.state.anchor.length > 0 && post.id == parseInt(this.state.anchor.replace(/#?post-/, ''))) || !post.read) {
          highlight = p;
          break;
        }
      }
    }
    this.setState({posts: objects, view: view});
  },
  updatedChannel: function(objects, view) {
    if(objects.length > 0) this.setState({channel: objects[0]});
  },
  loadMore: function() {
    Data.fetch(ChannelPostsData, this.props.channelId, {first_id: this.state.view.start_id});
  },
  render: function () {
    var anchorPostId = this.state.anchor == "" ? 0 : parseInt(this.state.anchor.replace(/#?post-/, ''))
    if(this.props.channelId > 0 && (this.state.posts.length < 1 || !this.state.channel.id)) return <LoadingIndicator />;
    if(this.props.channelId > 0) {
      var channelId = this.props.channelId;
      var highlight = this.state.highlight;
      var posts = this.state.posts.map(function(post, i) {
        var user = Data.get("user", post.user_id);
        return <ChannelPost key={post.id} id={post.id} highlight={i == highlight} channelId={channelId} user={user} post={post} />
      });
      var commentbox = <div>
        <a name="comments"></a>
        <h3 className="channel-response-title">Comment</h3>
        <div className="channel-response">
          <CommentBox channelId={channelId} />
        </div>
      </div>;
    }
    return <div>
      <ChannelPostsHeader channelId={this.props.channelId} channel={this.state.channel} />
      <ViewLoader callback={this.loadMore} visible={this.state.posts.length} count={this.state.view.count} message={"more posts"} />
      {posts}
      {commentbox}
    </div>;
  }
});

// module.exports = ChannelPosts;
window.ChannelPosts = ChannelPosts;
