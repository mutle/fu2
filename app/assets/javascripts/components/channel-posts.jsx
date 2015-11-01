// var React = require('react');
// var LoadingIndicator = require("./loading-indicator");

var ChannelPostsData = {
  url: "/api/channels/{id}/posts.json",
  result: {
    posts: ["post"],
    channel: "channel"
  },
  view: "channel-$ID-post",
  subscribe: [
    "post_create",
    "post_fave",
    "post_unfave"
  ]
};

function replyMessage(post) {
  $(".comment-box-form textarea").val(post.body.split("\n\n").map(function(l,i) { return "> "+l; }).join("\n\n")+"\n\n").select();
}

var ChannelPosts = React.createClass({
  getInitialState: function() {
    return {posts: [], channel: {}, view: {}, anchor: "", highlight: -1};
  },
  componentDidMount: function() {
    if(this.props.channelId > 0) {
      Data.subscribe("channel-"+this.props.channelId+"-post", this, 0, {callback: this.updatedPosts});
      Data.subscribe("channel", this, this.props.channelId, {callback: this.updatedChannel});
      Data.fetch(ChannelPostsData, this.props.channelId);
    }

    var self = this;
    this.keydownCallback = $(document).on("keydown", function(e) {
      if(!self.isMounted()) return;
      if(e.target != $("body").get(0)) return;
      if(e.ctrlKey || e.metaKey || e.shiftKey || e.altKey) return;
      var key = String.fromCharCode(e.keyCode);
      if(key == "J") {
        if(self.state.highlight+1 < self.state.posts.length)
          self.setState({highlight: self.state.highlight+1});
        else
          self.setState({highlight: 0});
        self.updateAnchor();
        e.preventDefault();
      }
      if(key == "K") {
        if(self.state.highlight > 0)
          self.setState({highlight: self.state.highlight-1});
        else
          self.setState({highlight: self.state.posts.length-1});
        self.updateAnchor();
        e.preventDefault();
      }
      if(key == "M") {
        self.loadMore();
        e.preventDefault();
      }
      if(key == "A") {
        self.loadAll();
        e.preventDefault();
      }
      if(key == "R") {
        if(self.state.highlight >= 0) {
          var post = self.state.posts[self.state.highlight];
          replyMessage(post);
          e.preventDefault();
        }
      }
    });
  },
  componentWillUnmount: function() {
    Data.unsubscribe(this);
    $(document).off("keydown", this.keydownCallback);
  },
  selectPost: function(post) {
    var h = "#post-"+post.id;
    if(document.location.hash != h) {
      history.pushState(null, null, location.pathname+h);
      if(this.isMounted())
        this.setState({anchor: h});
    }
    o = $(this.getDOMNode()).find(".post-"+post.id).offset();
    if(o) {
      $(window).scrollTop(o.top - 150);
      return true;
    }
    return false;
  },
  updateAnchor: function() {
    if(this.state.highlight >= 0) {
      var post = this.state.posts[this.state.highlight];
      if(post) {
        return this.selectPost(post);
        // var h = "#post-"+post.id;
        // if(h != document.location.hash)
          // document.location.hash = h;
      }
    }
    return false;
  },
  updatedPosts: function(objects, view) {
    highlight = this.state.highlight;
    var jump = false;
    if(highlight == -1) {
      for(var p in objects) {
        var post = objects[p];
        if((this.state.anchor.length > 0 && post.id == parseInt(this.state.anchor.replace(/#?post-/, '')))) {
          highlight = parseInt(p);
          jump = true;
          break;
        }
      }
    }
    this.setState({posts: objects, view: view, highlight: highlight, jump: true});
  },
  updatedChannel: function(objects, view) {
    if(objects.length > 0) this.setState({channel: objects[0]});
  },
  loadMore: function(e) {
    Data.fetch(ChannelPostsData, this.props.channelId, {first_id: this.state.view.start_id});
    e.preventDefault();
  },
  loadAll: function(e) {
    Data.fetch(ChannelPostsData, this.props.channelId, {last_id: 0, limit: this.state.view.count});
    e.preventDefault();
  },
  componentDidUpdate: function() {
    if(this.isMounted() && this.state.jump) {
      if(this.updateAnchor())
        this.setState({jump: false});
    }
  },
  render: function () {
    var anchorPostId = this.state.anchor == "" ? 0 : parseInt(this.state.anchor.replace(/#?post-/, ''))
    if(this.props.channelId > 0 && (this.state.posts.length < 1 || !this.state.channel.id)) return <LoadingIndicator />;
    if(this.props.channelId > 0) {
      var channelId = this.props.channelId;
      var highlight = this.state.highlight;
      var posts = this.state.posts.map(function(post, i) {
        var user = Data.get("user", post.user_id);
        return <ChannelPost key={post.id} id={post.id} highlight={i == highlight} channelId={channelId} user={user} post={post} editable={user.id == Data.user_id} />
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
      <ViewLoader callback={this.loadMore} callbackAll={this.loadAll} visible={this.state.posts.length} count={this.state.view ? this.state.view.count : 0} octicon={"chevron-up"} message={"older posts"} messageAll={"Show all"} />
      {posts}
      {commentbox}
    </div>;
  }
});

// module.exports = ChannelPosts;
window.ChannelPosts = ChannelPosts;
