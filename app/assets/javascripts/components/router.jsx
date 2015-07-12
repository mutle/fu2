// var React = require('react');

var Router = {
  responders: {},
  routes: {},
  content: null,
  route: function(path, updateUrl) {
    if(!path) return false;
    var urlpath = path;
    var hash = path.replace(/^.*#/, '');
    path = path.replace(/#.*$/, '');
    this.content = $(".content-inner").get(0);

    for(var name in this.routes) {
      var routes = this.routes[name];
      for(var routei in routes) {
        var route = routes[routei];
        console.log([path, name, route]);
        if(route && route.match) {
          var m = path.match(route.match);
          if(m) {
            var params = {anchor: hash};
            var i = 0;
            while(route.params && i < m.length - 1 && i < route.params.length) {
              params[route.params[i]] = m[i + 1];
              i++;
            }
            console.log("Route: "+path+" "+name);
            this.open(name, params, updateUrl, urlpath);
            return true;
          }
        }
      }
    }
    return false;
  },
  addResponder: function(name, callback, url) {
    this.responders[name] = {callback: callback, url: url};
  },
  addRoute: function(name, regex, params) {
    if(!this.routes[name]) this.routes[name] = [];
    this.routes[name].push({match: regex, params: params});
  },
  open: function(name, params, updateUrl, urlpath) {
    var responder = this.responders[name];
    responder.callback(params, this.content);
    if(urlpath) {
      history.pushState(null, null, urlpath);
    } else if(responder.url && updateUrl) {
      var url = responder.url(params);
      console.log(url);
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
  }, function(params) {
    var post_id = params.post_id ? "#post-"+params.post_id : "";
    return "/channels/"+params.channel_id+post_id;
  });

  Router.addResponder("channels/list", function(params, e) {
    var channels = React.render(<ChannelList />, e);
  }, function(params) { return "/"; });

  Router.addResponder("channels/new", function(params, e) {
    var posts = React.render(<ChannelPosts channelId={0} />, e);
  });

  Router.addResponder("notifications/index", function(params, e) {
    var notifications = React.render(<Notifications />, e);
  });

  Router.addRoute("channels/new", /^\/channels\/new\/?$/);
  Router.addRoute("channels/show", /^\/channels\/([0-9]+)\/?$/, ["channel_id"]);
  Router.addRoute("channels/list", /^\/(channels)?\/?$/);
  Router.addRoute("notifications/index", /^\/notifications\/?$/);

  Router.route(document.location.pathname);

  $(window).bind("popstate", function(e) {
    if(Router.route(document.location.pathname, true)) {
      e.preventDefault();
      return false;
    }
    return true;
  });

  $(document).on("click", "a", function(e) {
    console.log(e);
    if(!e.metaKey && !e.ctrlKey && !e.altKey && Router.route($(this).attr("href"), true)) {
      e.preventDefault();
      return false;
    }
    e.preventDefault();
    return true;
  });
});

// module.exports = Router;
window.Router = Router;
