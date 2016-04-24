var Navigation = React.createClass({
  getInitialState: function() {
    return {showNotifications: false, showMore: false, showHotkeys: false, showSites: false};
  },
  render: function() {
    return <div className="inside">
      <Popover key="more" style={"more"} show={this.state.showMore} relativeCallback={this.moreParent} renderCallback={this.renderMore} exitCallback={this.hideAll} />
      <Popover key="notifications" style={"top-left"} show={this.state.showNotifications} relativeCallback={this.notificationsParent} renderCallback={this.renderNotifications} exitCallback={this.hideAll} />
      <Popover key="sites" style={"top-center"} show={this.state.showSites} renderCallback={this.renderSites} exitCallback={this.hideAll} />
      <Popover key="hotkeys" style={"main"} show={this.state.showHotkeys} renderCallback={this.renderHotkeys} exitCallback={this.hideAll} />
    </div>;
  },
  hideAll: function() {
    this.setState(this.getInitialState());
  },
  renderMore: function(p) {
    var info = {__html: $(".more-container").get(0).innerHTML};
    return <div dangerouslySetInnerHTML={info} />;
  },
  renderNotifications: function(p) {
    return <NotificationList count={6} small={true} />;
  },
  renderHotkeys: function(p) {
    return <Hotkeys popover={p} navigation={this} />;
  },
  renderSites: function(p) {
    return <SiteSwitcher />;
  },
  moreParent: function() {
    return $(".toolbar-more-link").get(0);
  },
  notificationsParent: function() {
    return $(".counters").get(0);
  }
});

$(function() {
  var nav = $("#pre-content");
  if(nav.length > 0) {
    var navigation = ReactDOM.render(<Navigation />, nav.get(0));
  }

  console.log(navigation);

  var counters = $(".header .counters");
  if(counters.length > 0) {
    var counter = ReactDOM.render(<NotificationCounter navigation={navigation} />, counters.get(0));
    counter.connect();
  }

  $(document).on("click", "a.toolbar-more-link", function(e) {
    navigation.setState({showMore: !navigation.state.showMore});
    e.preventDefault();
  });

  $(document).on("click", "a.toolbar-info", function(e) {
    navigation.setState({showHotkeys: !navigation.state.showHotkeys});
    e.preventDefault();
  });

  $(document).on("click", "a.toolbar-sites", function(e) {
    navigation.setState({showSites: !navigation.state.showSites});
    e.preventDefault();
  });

  $(document).bind("keydown", "esc", function(e) {
    if(e.target != $("body").get(0)) return;
    navigation.hideAll();
  });

  $(document).bind("keydown", "shift+/", function(e) {
    if(e.target != $("body").get(0)) return;
    navigation.setState({showHotkeys: !navigation.state.showHotkeys});
    e.preventDefault();
  });

});

// module.exports = Navigation;
window.Navigation = Navigation;
