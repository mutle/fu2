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
    "channel_read",
    "offline_channel_list"
  ]
};
var ChannelListTagData = {
  url: "/api/channels.json",
  result: {
    channels: ["channel"]
  },
  view: "channel-tag-$ID",
  subscribe: []
};
var ChannelListFilterData = {
  url: "/api/channels.json",
  result: {
    channels: ["channel-filtered"]
  },
  view: "channel-filtered",
  noCache: true,
  subscribe: [
    "channel_update",
    "channel_create",
    "channel_read",
    "offline_channel_list"
  ]
};

var ChannelListFilter = React.createClass({
  getInitialState: function() {
    return {show: false, text: "", unread: false, date: ""};
  },
  reset: function(e) {
    e.preventDefault();
    var self = this;
    if(this.props.channelList.state.showQuery) {
      document.location.hash = "";
      if(this.props.channelList.isMounted())
        this.props.channelList.setState({showQuery: false});
    }
    if(this.isMounted()) {
      this.setState(this.getInitialState(), function(e) {
        self.updateQuery(self.state);
      });
    }
  },
  onChange: function(e) {
    var query = e.target.value;
    var n = this.state.n + 1;
    var key = e.target.className == "text-filter" ? "text" : "date";
    var s = {};
    s[key] = query;
    s.show = query.length > 0 || this.state.unread;
    var self = this;
    this.setState(s, function(e) {
      self.updateQuery(self.state);
    });
  },
  onKeydown: function(e) {
    if(e.keyCode == 27) {
      this.reset(e);
    }
    if(e.keyCode == 13) {
      e.preventDefault();
      var url = this.searchUrl();
      document.location.href = url;
    }
  },
  toggleUnread: function(e) {
    var self = this;
    this.setState({unread: e.target.checked, show: e.target.checked || this.state.text.length > 0}, function(e) {
      self.updateQuery(self.state);
    });
  },
  updateQuery: function(q) {
    this.props.channelList.filter(q);
  },
  searchUrl: function() {
    return "/search/"+encodeURIComponent(this.state.text);
  },
  render: function() {
    var _1 = <span className="group"><input className="unread-filter" type="checkbox"  checked={this.state.unread} onChange={this.toggleUnread} /> Unread</span>;
    var _2 = <span className="group"><input placeholder="Date" className="date-filter" value={this.state.date} onKeyDown={this.onKeydown} onChange={this.onChange} /></span>;
    if(this.state.text.length > 0) {
      var searchUrl = this.searchUrl();
      var searchLink = <a className="search" href={searchUrl}>Search for <em>{this.state.text}</em></a>;
    }
    var className = "filter";
    if(this.props.channelList.state.showQuery || this.state.show) className += " show";
    return <div className={className}>
      <a className="close-link" href="#" onClick={this.reset}><span className="octicon octicon-x" /></a>
      <div className="group first"><input placeholder="Title" className="text-filter" value={this.state.text} onKeyDown={this.onKeydown} onChange={this.onChange} /></div>
      <div className="group"><input type="checkbox" className="read-filter" checked={this.state.unread} onChange={this.toggleUnread} /> Only unread</div>
      {searchLink}
    </div>;
  }
});

var Channel = React.createClass({
  render: function() {
    var className = "channel channel-"+this.props.channel.id;
    if(this.props.channel.read) className += " read";
    if(this.props.highlight) className += " highlight";
    var url = Data.url_root + "/channels/"+this.props.channel.id+"#post-"+this.props.channel.last_post_id;
    var displayName = this.props.channel.display_name;
    var channelName = {__html: displayName};
    return <li>
      <div className={className}>
        <div className="timestamp">
          <Timestamp timestamp={this.props.channel.display_date} />
        </div>
        <UserLink user={this.props.user} />
        <a className="channel-name" href={url} dangerouslySetInnerHTML={channelName}></a>
      </div>
    </li>;
  }
});

var ChannelList = React.createClass({
  getInitialState: function() {
    return {channels: [], channels_filtered: [], view: {}, view_filtered: {}, highlight: -1, highlight_filtered: -1, query: null};
  },
  hotkeys: function() {
    return {
      "ctrl+u": {
        name: "Jump to Top",
        callback: function() {
          this.setState({highlight: 0});
          this.scrollToHighlight();
        }
      },
      "ctrl+d": {
        name: "Jump to Bottom",
        callback: function() {
          this.setState({highlight: this.state.channels.length - 1});
          this.scrollToHighlight();
        }
      },
      "j": {
        name: "Next Channel",
        callback: function() {
          if(this.state.highlight < this.state.channels.length - 1) {
            this.setState({highlight: this.state.highlight+1});
            this.scrollToHighlight();
          }
        }
      },
      "k": {
        name: "Previous Channel",
        callback: function() {
          if(this.state.highlight > 0) {
            this.setState({highlight: this.state.highlight-1});
            this.scrollToHighlight();
          }
        }
      },
      "o": {
        alternative: [ "return" ],
        name: "Open Channel",
        callback: function() {
          if(this.state.highlight >= 0 && this.state.channels.length >= this.state.highlight) {
            Router.open("channels/show",{channel_id: this.state.channels[this.state.highlight].id}, true);
          }
        }
      },
      "s": {
        alternative: [ "f" ],
        name: "Search Channels",
        callback: function() {
          if(this.channelListFilter)
            this.channelListFilter.setState({show: true});
          $(".filter .text-filter").focus();
        }
      }
    }
  },
  componentDidMount: function() {
    var self = this;
    $(window).scrollTop(0);
    if(this.props.tag) {
      Data.subscribe("channel-tag-"+this.props.tag, this, 0, {callback: this.updated});
      Data.fetch(ChannelListTagData, this.props.tag, {tag: this.props.tag}, this.fetchUpdatedChannels, this.loadError);
    } else {
      Data.subscribe("channel", this, 0, {callback: this.updated});
      Data.subscribe("channel-filtered", this, 0, {callback: this.updated});
      Data.fetch(ChannelListData, 0, {tag: this.props.tag}, this.fetchUpdatedChannels, this.loadError);
    }
  },
  loadError: function(e) {
    this.setState({error: true});
  },
  scrollToHighlight: function() {
    if(this.state.highlight >= 0) {
      var channel = this.state.channels[this.state.highlight];
      if(channel) {
        o = $(ReactDOM.findDOMNode(this)).find(".channel-"+channel.id).offset();
        if(o) {
          $(window).scrollTop(o.top - 150);
        }
      }
    }
  },
  componentDidUpdate: function() {
    if(this.state.showQuery && !this.state.showingQuery) {
      this.setState({showingQuery: true});
      $(ReactDOM.findDOMNode(this)).find(".text-filter").focus()
    }
  },
  componentWillUnmount: function() {
    Data.unsubscribe(this, ChannelListData.subscribe);
  },
  updated: function(objects, view) {
    var sorted = objects.sort(function(a,b) { return b.display_date - a.display_date; });
    var highlight = this.state.hightlight;
    if(highlight == -1) {
      for(var c in sorted) {
        var chan = sorted[c];
        if(!chan.read) {
          highlight = c;
          break;
        }
      }
    }
    if(view.type == "channel-filtered") {
      this.setState({channels_filtered: sorted, view_filtered: view, highlight_filtered: highlight});
    } else {
      this.setState({channels: sorted, view: view, highlight: highlight});
    }
  },
  filter: function(filter) {
    var query = {};
    var filtering = false;
    if(filter && filter.text.length > 0) {
      query["text"] = filter.text;
      filtering = true;
    }
    if(filter && filter.unread) {
      query["unread"] = true;
      filtering = true;
    }
    if(filtering) {
      if(this.filter_request)
        window.clearTimeout(this.filter_request);
      this.filter_request = window.setTimeout(function() {
        Data.fetch(ChannelListFilterData, 0, {query: query});
        this.filter_request = null;
      }, 500);
    } else {
      query = null;
      Data.fetch(ChannelListData, 0, {tag: this.props.tag});
      if(this.props.tag) {
        Data.fetch(ChannelListTagData, this.props.tag, {tag: this.props.tag});
      } else {
        Data.fetch(ChannelListData, 0, {tag: this.props.tag});
      }
    }
    this.setState({query: filter});
  },
  loadMore: function(e) {
    if(this.state.query) {
      Data.fetch(ChannelListData, 0, {page: this.state.view_filtered.page + 1, query: this.state.query});
    } else {
      if(this.props.tag) {
        Data.fetch(ChannelListTagData, this.props.tag, {tag: this.props.tag, page: this.state.view.page + 1});
      } else {
        Data.fetch(ChannelListData, 0, {page: this.state.view.page + 1});
      }
    }
    e.preventDefault();
  },
  fetchUpdatedChannels: function() {
    if(this.state.view) {
      if(this.state.query && this.state.query.show) {
        Data.fetch(ChannelListFilterData, 0, {query: this.state.query, last_update: this.state.view_filtered.last_update + 1}, this.fetchUpdatedChannels);
      } else {
        if(this.props.tag) {
          Data.fetch(ChannelListTagData, this.props.tag, {tag: this.props.tag, last_update: this.state.view.last_update + 1});
        } else {
          Data.fetch(ChannelListData, 0, {last_update: this.state.view.last_update + 1});
        }
      }
    }
  },
  activeChannels: function() {
    if(this.state.query && this.state.query.show) {
      return this.state.channels_filtered;
    }
    return this.state.channels;
  },
  activeView: function() {
    if(this.state.query && this.state.query.show) {
      return this.state.view_filtered;
    }
    return this.state.view;
  },
  activeHighlight: function() {
    if(this.state.query && this.state.query.show) {
      return this.state.highlight_filtered;
    }
    return this.state.highlight;
  },
  render: function() {
    if(this.state.error) return <ErrorMessage title="Failed to load channels" />;
    if(!this.state.view.page && this.state.channels.length < 1) return <LoadingIndicator />;
    if(this.state.channels.length < 1) return <div>No Channels</div>;
    var highlightId = this.activeHighlight();
    var query = null;
    if(this.state.query) query = this.state.query.text;
    var activeChannels = this.activeChannels();
    var activeView = this.activeView();
    var channels = activeChannels.map(function(channel, i) {
      var user = Data.get("user", channel.last_post_user_id);
      var highlight = (i == highlightId);
      return <Channel key={channel.id} id={channel.id} user={user} channel={channel} highlight={highlight} query={query} />;
    });
    var self = this;
    var refFunc = function(ref) { self.channelListFilter = ref; };
    return <div className="channel-list-container">
      <ChannelListFilter ref={refFunc} channelList={this} />
      <ul className="channel-list refresh">
        {channels}
      </ul>
      <ViewLoader callback={this.loadMore} visible={activeChannels.length} octicon="chevron-down" count={activeView.count} message={"older channels"} />
    </div>;
  }
});

// module.exports = ChannelList;
window.ChannelList = ChannelList;
