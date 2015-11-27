var SiteSwitcher = React.createClass({
  getInitialState: function() {
    return {show: true, sites: []};
  },
  componentDidMount: function() {
    var self = this;
    Data.action("index", "sites", [], {}, {
      success: function(data) {
        self.setState({sites: data.sites});
      }
    });
  },
  close: function(e) {
    e.preventDefault();
    this.setState({show: false});
  },
  render: function() {
    if(!this.state.show) return null;
    var sites = this.state.sites.map(function(site, i) {
      return <a href={"/"+site.path}>{site.name}</a>;
    });
    return <div className="site-switcher dialog">
      <span className="close octicon octicon-x" onClick={this.close} />
      <div className="content">
        <h3>Switch to Site</h3>
        {sites}
      </div>
    </div>;
  }
});

// module.exports = SiteSwitcher;
window.SiteSwitcher = SiteSwitcher;
