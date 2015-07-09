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
    return <div className="channel-post-header">
      <a className="avatar" href={userLink}><img className="avatar-image" src={this.props.user.avatar_url} /></a>
      <span className="user-name">{this.props.user.login}</span>
      <div className="right">
        {postDeleteLink}
        {postEditLink}
        <FaveCounter faves={this.props.post.faves} postId={this.props.id}  />
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
    return {posts: [], channel: {}, anchor: ""};
  },
  componentDidMount: function() {
    if(this.props.channelId > 0) {
      console.log(this.props.channelId);
      Data.subscribe("post", this.updatedPosts, this, this.props.channelId);
      Data.subscribe("channel", this.updatedChannel, this);
      Data.fetch(ChannelPostsData, this.props.channelId);
    }

    var c = this;
    $(document).on("keypress", function(e) {
      var key = String.fromCharCode(e.charCode);
      if(e.target.tagName != "BODY") return true
      switch(e.key) {
        case "j":
          c.nextAnchor();
          break;
        case "k":
          c.previousAnchor();
          break;
      }
    });
  },
  selectPost: function(post) {
    var h = "post-"+this.state.posts[0].id;
    this.setState({anchor: h});
    document.location.hash = h;
    console.log($(this.getDOMNode()).find(".post-"+post.id).offset().top)
    $(window).scrollTop($(this.getDOMNode()).find(".post-"+post.id).offset().top)
  },
  nextAnchor: function() {
    if(this.state.anchor == "") {
      this.selectPost(this.state.posts[this.state.posts.length - 1]);
    } else {
      var anchorPostId = this.state.anchor.replace(/#?post-/, '');
      var getnext = false
      for(var i in this.state.posts) {
        var post = this.state.posts[i];
        if(post) {
          if(getnext) {
            this.selectPost(post);
            return;
          } else if(post.id == anchorPostId) {
            getnext = true;
          }
        }
      }
    }
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
    var anchorPostId = this.state.anchor == "" ? 0 : parseInt(this.state.anchor.replace(/#?post-/, ''))
    if(this.props.channelId > 0 && (this.state.posts.length < 1 || !this.state.channel.id)) return <LoadingIndicator />;
    if(this.props.channelId > 0) {
      var channelId = this.props.channelId;
      var posts = this.state.posts.map(function(post, i) {
        var user = Data.get("user", post.user_id);
        return <ChannelPost key={post.id} id={post.id} highlight={anchorPostId == post.id} channelId={channelId} user={user} post={post} />
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
      {posts}
      {commentbox}
    </div>;
  }
});

// module.exports = ChannelPosts;
window.ChannelPosts = ChannelPosts;
