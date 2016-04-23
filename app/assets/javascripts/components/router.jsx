// var React = require('react');

var Router = {
  responders: {},
  hotkeys: {},
  local_hotkeys: null,
  hotkey_groups: {},
  current_name: "",
  routes: {},
  content: null,
  current: null,
  route: function(path, updateUrl) {
    if(!path) return false;
    if(path == "#") return false;
    var m = path.match(/^https?:\/\/([^\/]+)(\/.*)$/)
    var host = null;
    if(m) {
      host = m[1].split(":")[0];
      path = m[2];
    }
    if(host != null && host != document.location.hostname) return;
    if(path.indexOf(Data.url_root) != 0) return;
    path = path.slice(Data.url_root.length);
    var urlpath = path;
    var hash = path.replace(/^.*#/, '');
    if(hash == path) hash = "";
    var params = {anchor: hash};
    path = path.replace(/#.*$/, '');
    this.content = $(".content-inner").get(0);

    for(var name in this.routes) {
      var routes = this.routes[name];
      for(var routei in routes) {
        var route = routes[routei];
        if(route && route.match) {
          var m = path.match(route.match);
          if(m) {
            var i = 0;
            while(route.params && i < m.length - 1 && i < route.params.length) {
              params[route.params[i]] = m[i + 1];
              i++;
            }
            console.log("Route: "+path+" "+name+"#"+hash);
            this.open(name, params, updateUrl, urlpath);
            return true;
          }
        }
      }
    }
    return false;
  },
  addResponder: function(name, callback, url, options) {
    this.responders[name] = {callback: callback, url: url, options: options};
    for(var o in options) {
      var opt = options[o];
      if(o == "hotkey") {
        this.hotkeys[opt] = name;
        var self = this;
        $(document).bind('keydown', opt, function(e) {
          self.open(name, {}, true);
          e.preventDefault();
        });
      }
    }
  },
  bindKeys: function(hotkeys, local, current, name, target) {
    if(!local) {
      this.hotkey_groups[name] = {};
    }
    for(var k in hotkeys) {
      if(!hotkeys[k].callback) continue;
      var f = function(key) {
        return function(e) {
          e.preventDefault();
          hotkeys[key].callback.apply(current, [e]);
        };
      }(k);
      if(!target) target = document;
      $(target).bind('keydown', k, f);
      if(local) {
        this.local_hotkeys[k] = {callback: f, hotkey: hotkeys[k]};
      } else {
        this.hotkey_groups[name][k] = {callback: f, hotkey: hotkeys[k]};
      }
      var a = hotkeys[k].alternative;
      if(a) {
        for(var ai in a) {
          var ak = a[ai];
          $(target).bind('keydown', ak, f);
          if(local) {
            this.local_hotkeys[ak] = {callback: f, alias: ai};
          } else {
            this.hotkey_groups[name][ak] = {callback: f, alias: ai};
          }
        }
      }
    }
  },
  unbindKeys: function(keys, target) {
    if(keys) {
      if(!target) target = document;
      for(var k in keys) {
        $(target).unbind('keydown', keys[k].callback);
      }
    }
  },
  addRoute: function(name, regex, params) {
    if(!this.routes[name]) this.routes[name] = [];
    this.routes[name].push({match: regex, params: params});
  },
  open: function(name, params, updateUrl, urlpath) {
    var responder = this.responders[name];
    this.current_name = responder && responder.options ? responder.options.name : null;
    document.title = "Red Cursor";
    if(this.local_hotkeys) {
      this.unbindKeys(this.local_hotkeys);
      this.local_hotkeys = null;
    }
    ReactDOM.unmountComponentAtNode(this.content);
    this.current = responder.callback(params, this.content);
    if(this.current.hotkeys) {
      this.local_hotkeys = {};
      var hotkeys = this.current.hotkeys();
      var current = this.current;
      this.bindKeys(hotkeys, true, current);
    }
    if(urlpath) {
      history.pushState(null, null, Data.url_root + urlpath);
    } else if(responder.url && updateUrl) {
      var url = Data.url_root + responder.url(params);
      history.pushState(null, null, url);
    }
  }
};

$(function() {
  Router.addResponder("channels/show", function(params, e) {
    var channel_id = parseInt(params.channel_id);
    var posts = ReactDOM.render(<ChannelPosts channelId={channel_id} />, e);
    var anchor = params.anchor ? params.anchor : params.post_id ? "post-"+params.post_id : document.location.hash;
    posts.setState({anchor: anchor});
    return posts;
  }, function(params) {
    var post_id = params.post_id ? "#post-"+params.post_id : "";
    return "/channels/"+params.channel_id+post_id;
  }, {name: "Channel Posts"});

  Router.addResponder("channels/tag", function(params, e) {
    var tag = ReactDOM.render(<ChannelTag tag={params.tag} />, e);
    return tag;
  }, function(params) { return "/channels/tags/"+params.tag; }, {name: "Channel Tag"});

  Router.addResponder("channels/list", function(params, e) {
    var channels = ReactDOM.render(<ChannelList />, e);
    if(params.anchor && params.anchor == "search") channels.setState({showQuery: true});
    return channels;
  }, function(params) { return "/"+(params.anchor ?  "#"+params.anchor : ""); }, {hotkey: "H", name: "Home"});

  Router.addResponder("channels/new", function(params, e) {
    return ReactDOM.render(<ChannelPosts channelId={0} />, e);
  }, function(params) { return "/channels/new"; }, {hotkey: "N", name: "New Channel"});

  Router.addResponder("notifications/index", function(params, e) {
    return ReactDOM.render(<Notifications />, e);
  }, function(params) { return "/notifications"; }, {hotkey: "M", name: "Notifications"});

  Router.addResponder("notifications/list", function(params, e) {
    return ReactDOM.render(<NotificationList />, e);
  }, function(params) { return "/notifications/list"; }, {name: "Notification List"});

  Router.addResponder("notifications/show", function(params, e) {
    return ReactDOM.render(<Notifications userId={params.user_id} />, e);
  }, function(params) { return "/notifications/"+params.user_id; }, {name: "Notifications"});

  Router.addResponder("users/settings", function(params, e) {
    $(".more").hide();
    var user = Data.get("user", Data.user_id);
    return ReactDOM.render(<UserSettings user={user} />, e);
  }, function(params) { return "/users/settings"; }, {name: "Settings"});

  Router.addResponder("users/show", function(params, e) {
    return ReactDOM.render(<UserProfile userId={params.user_id} />, e);
  }, function(params) { return "/users/"+params.user_id; }, {name: "User"});

  Router.addResponder("users/list", function(params, e) {
    return ReactDOM.render(<UserList users={window.Users} />, e);
  }, function(params) { return "/users"; }, {hotkey: "U", name: "User List"});

  Router.addResponder("posts/search", function(params, e) {
    var search = ReactDOM.render(<ChannelPostsSearch />, e);
    if(params.sort) search.setState({sort: params.sort});
    if(params.query) search.performQuery(decodeURIComponent(params.query));
    return search;
  }, function(params) { return "/search/"+params.query; }, {name: "Search results"});

  Router.addRoute("channels/new", /^\/channels\/new\/?$/);
  Router.addRoute("channels/tag", /^\/channels\/tags\/([^\/]+)\/?$/, ["tag"]);
  Router.addRoute("channels/show", /^\/channels\/([0-9]+)\/?$/, ["channel_id"]);
  Router.addRoute("notifications/index", /^\/notifications\/?$/);
  Router.addRoute("notifications/list", /^\/notifications\/list\/?$/);
  Router.addRoute("notifications/show", /^\/notifications\/([^\/]+)\/?$/, ["user_id"]);
  Router.addRoute("users/settings", /^\/settings\/?$/);
  Router.addRoute("users/show", /^\/users\/([^\/]+)\/?$/, ["user_id"]);
  Router.addRoute("users/list", /^\/users\/?$/);
  Router.addRoute("posts/search", /^\/search\/([^\/]*)\/([^\/]*)\/?$/, ["query", "sort"]);
  Router.addRoute("posts/search", /^\/search\/([^\/]*)\/?$/, ["query"]);
  Router.addRoute("posts/search", /^\/search\/?$/);
  Router.addRoute("channels/list", /^(\/channels)?\/?$/);

  Router.route(document.location.pathname+document.location.hash);

  var hotkeys = null;
  var switcher = null;

  $(document).bind("keydown", "shift+/", function(e) {
    if(e.target != $("body").get(0)) return;
    if(!hotkeys) hotkeys = ReactDOM.render(<Hotkeys />, $("#pre-content").get(0));
    hotkeys.setState({show: !hotkeys.state.show});
    e.preventDefault();
  });

  $(document).bind("keydown", "esc", function(e) {
    if(e.target != $("body").get(0) || !hotkeys || !hotkeys.state.show) return;
    hotkeys.setState({show: false});
  });

  $(document).on("click", "a.toolbar-sites", function(e) {
    hotkeys = null;
    if(!switcher)
      switcher = ReactDOM.render(<SiteSwitcher />, $("#pre-content").get(0));
    switcher.setState({show: true});
    e.preventDefault();
  });

  $(document).on("click", "a.toolbar-info", function(e) {
    if(!hotkeys) hotkeys = ReactDOM.render(<Hotkeys />, $("#pre-content").get(0));
    hotkeys.setState({show: !hotkeys.state.show});
    e.preventDefault();
  });

  $(window).bind("popstate", function(e) {
    if(Router.route(document.location.pathname, true)) {
      e.preventDefault();
      return false;
    }
    return true;
  });

  $(document).on("click", "a.toolbar-more-link", function(e) {
    $(".more").toggle();
    e.preventDefault();
  });

  $(document).on("click", "a", function(e) {
    if(!e.metaKey && !e.ctrlKey && !e.altKey && !e.shiftKey && e.button == 0 && Router.route($(this).attr("href"), true)) {
      e.preventDefault();
      return false;
    }
  });

  $(document).on('scroll', function(e) {
    if(document.body.scrollTop < document.body.scrollHeight - document.body.clientHeight)
      $(".bottom-link .octicon").removeClass("octicon-arrow-up").addClass("octicon-arrow-down");
    else
      $(".bottom-link .octicon").removeClass("octicon-arrow-down").addClass("octicon-arrow-up");
  });

  $(".bottom-link").click(function(e) {
    e.preventDefault();
    if($(this).find(".octicon").hasClass("octicon-arrow-up"))
      window.scrollTo(0,0);
    else
      window.scrollTo(0,document.body.scrollHeight);
    return false
  });
});

// module.exports = Router;
window.Router = Router;
