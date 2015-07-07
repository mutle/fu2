// var React = require('react');

var Router = {
  responders: {},
  routes: {},
  content: null,
  route: function() {
    this.content = $(".content-inner").get(0);
    var path = document.location.pathname;

    for(var name in this.routes) {
      var routes = this.routes[name];
      for(var routei in routes) {
        var route = routes[routei];
        console.log([path, name, route]);
        if(route && route.match) {
          var m = path.match(route.match);
          if(m) {
            var params = {};
            var i = 0;
            while(route.params && i < m.length - 1 && i < route.params.length) {
              params[route.params[i]] = m[i + 1];
              i++;
            }
            console.log("Route: "+path+" "+name)
            this.open(name, params);
            return;
          }
        }
      }
    }
  },
  addResponder: function(name, callback, url) {
    this.responders[name] = {callback: callback, url: url};
  },
  addRoute: function(name, regex, params) {
    if(!this.routes[name]) this.routes[name] = [];
    this.routes[name].push({match: regex, params: params});
  },
  open: function(name, params, updateUrl) {
    var responder = this.responders[name];
    responder.callback(params, this.content);
    if(responder.url && updateUrl) {
      var url = responder.url(params);
      console.log(url)
      history.pushState(null, null, url);
    }
  }
}

$(function() {
  Router.addResponder("channels/show", function(params, e) {
    var channel_id = parseInt(params.channel_id)
    var posts = React.render(<ChannelPosts channelId={channel_id} />, e);
  }, function(params) { return "/channels/"+params.channel_id; });

  Router.addResponder("channels/list", function(params, e) {
    var channels = React.render(<ChannelList />, e);
  });

  Router.addResponder("notifications/index", function(params, e) {
    var notifications = React.render(<Notifications />, e);
  })

  Router.addRoute("channels/show", /^\/channels\/([0-9]+)\/?$/, ["channel_id"]);
  Router.addRoute("channels/list", /^\/(channels)?\/?$/);
  
  Router.addRoute("notifications/index", /^\/notifications\/?$/);

  Router.route();

  $(window).bind("popstate", function() {
    Router.route();
    return false;
  });
});

// module.exports = Router;
window.Router = Router;
