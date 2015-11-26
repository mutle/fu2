// var React = require('react');

var Router = {
  responders: {},
  hotkeys: {},
  local_hotkeys: null,
  current_name: "",
  routes: {},
  content: null,
  current: null,
  route: function(path, updateUrl) {
    if(!path) return false;
    console.log(path);
    var m = path.match(/^https?:\/\/([^\/]+)(\/.*)$/)
    if(m) {
      console.log(m[1]);
      path = m[2];
    }
    var urlpath = path;
    var hash = path.replace(/^.*#/, '');
    if(hash == path) hash = "";
    var params = {anchor: hash};
    console.log(params);
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
  addRoute: function(name, regex, params) {
    if(!this.routes[name]) this.routes[name] = [];
    this.routes[name].push({match: regex, params: params});
  },
  open: function(name, params, updateUrl, urlpath) {
    var responder = this.responders[name];
    this.current_name = responder && responder.options ? responder.options.name : null;
    document.title = "Red Cursor";
    if(this.local_hotkeys) {
      for(var k in this.local_hotkeys) {
        $(document).unbind('keydown', this.local_hotkeys[k]);
      }
      this.local_hotkeys = null;
    }
    React.unmountComponentAtNode(this.content);
    this.current = responder.callback(params, this.content);
    if(this.current.hotkeys) {
      this.local_hotkeys = {};
      var hotkeys = this.current.hotkeys();
      var current = this.current;
      for(var k in hotkeys) {
        if(!hotkeys[k].callback) continue;
        var f = function(key) {
          return function(e) {
            e.preventDefault();
            hotkeys[key].callback.apply(current, [e]);
          };
        }(k);
        $(document).bind('keydown', k, f);
        this.local_hotkeys[k] = f;
        var a = hotkeys[k].alternative;
        if(a) {
          for(var ai in a) {
            var ak = a[ai];
            $(document).bind('keydown', ak, f);
            this.local_hotkeys[ak] = f;
          }
        }
      }
    }
    if(urlpath) {
      history.pushState(null, null, urlpath);
    } else if(responder.url && updateUrl) {
      var url = responder.url(params);
      history.pushState(null, null, url);
    }
  }
};

$(function() {
  Router.addResponder("channels/show", function(params, e) {
    var channel_id = parseInt(params.channel_id);
    var posts = React.render(<ChannelPosts channelId={channel_id} />, e);
    var anchor = params.anchor ? params.anchor : params.post_id ? "post-"+params.post_id : document.location.hash;
    posts.setState({anchor: anchor});
    return posts;
  }, function(params) {
    var post_id = params.post_id ? "#post-"+params.post_id : "";
    return "/channels/"+params.channel_id+post_id;
  }, {name: "Channel Posts"});

  Router.addResponder("channels/list", function(params, e) {
    var channels = React.render(<ChannelList />, e);
    console.log(params.anchor);
    if(params.anchor && params.anchor == "search") channels.setState({showQuery: true});
    return channels;
  }, function(params) { return "/"+(params.anchor ?  "#"+params.anchor : ""); }, {hotkey: "H", name: "Home"});

  Router.addResponder("channels/new", function(params, e) {
    return React.render(<ChannelPosts channelId={0} />, e);
  }, function(params) { return "/channels/new"; }, {hotkey: "N", name: "New Channel"});

  Router.addResponder("notifications/index", function(params, e) {
    return React.render(<Notifications />, e);
  }, function(params) { return "/notifications"; }, {hotkey: "M", name: "Notifications"});

  Router.addResponder("users/settings", function(params, e) {
    $(".more").hide();
    var user = Data.get("user", Data.user_id);
    return React.render(<UserSettings user={user} />, e);
  }, function(params) { return "/users/settings"; }, {name: "Settings"});

  Router.addResponder("users/show", function(params, e) {
    return React.render(<UserProfile userId={params.user_id} />, e);
  }, function(params) { return "/users"+params.user_id; }, {name: "User"});

  Router.addResponder("users/list", function(params, e) {
    return React.render(<UserList users={window.Users} />, e);
  }, function(params) { return "/users"; }, {hotkey: "U", name: "User List"});

  Router.addRoute("channels/new", /^\/channels\/new\/?$/);
  Router.addRoute("channels/show", /^\/channels\/([0-9]+)\/?$/, ["channel_id"]);
  Router.addRoute("channels/list", /^\/(channels)?\/?$/);
  Router.addRoute("notifications/index", /^\/notifications\/?$/);
  Router.addRoute("users/settings", /^\/settings\/?$/);
  Router.addRoute("users/show", /^\/users\/([^\/]+)\/?$/, ["user_id"]);
  Router.addRoute("users/list", /^\/users\/?$/);

  Router.route(document.location.pathname+document.location.hash);

  var hotkeys = React.render(<Hotkeys />, $("#pre-content").get(0));

  $(document).bind("keydown", "shift+/", function(e) {
    if(e.target != $("body").get(0)) return;
    hotkeys.setState({show: !hotkeys.state.show});
    e.preventDefault();
  });

  $(document).bind("keydown", "esc", function(e) {
    if(e.target != $("body").get(0) || !hotkeys.state.show) return;
    hotkeys.setState({show: false});
  });

  $(document).on("click", "a.toolbar-info", function(e) {
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
