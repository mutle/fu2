var ChannelPostsSearchHelp = React.createClass({
  getInitialState: function() {
    return {show: false, props: null};
  },
  toggle: function(e) {
    e.preventDefault();
    if(!this.state.show && !this.state.props) {
      var self = this;
      Data.action("advanced_search", "post", [], {}, {error: function() {
        console.log("Search failed.");
      }, success: function(data) {
        self.setState({show: true, props: data.posts});
      }});
    } else {
      this.setState({show: !this.state.show});
    }
  },
  render: function() {
    if(this.state.show && this.state.props) {
      return <span>
        <a href="#" className="toggle-help" onClick={this.toggle}>Hide Help</a>
        <div className="help">
          <p>The following attributes can be queried directly using attribute:search</p>
          <p>{this.state.props.join(" ")}</p>
        </div>
      </span>;
    } else {
      return <a href="#" className="toggle-help" onClick={this.toggle}>Help</a>;
    }
  }
});

var ChannelPostsSearch = React.createClass({
  getInitialState: function() {
    return {query: null, results: null, view: null, sort: "score", showSortMenu: false, loading: true};
  },
  componentDidMount: function() {
    if(this.state.query)
      this.performQuery(this.state.query);
  },
  reset: function(e) {
    e.preventDefault();
    var self = this;
    if(this.isMounted()) {
      if(this.state.query) history.pushState(null, null, "/search");
      this.setState(this.getInitialState());
    }
  },
  search: function(e) {
    e.preventDefault();
    if(this.state.query)
      this.performQuery(this.state.query);
  },
  onChange: function(e) {
    var query = e.target.value;
    this.performQuery(query);
  },
  onKeydown: function(e) {
    if(e.keyCode == 27) {
      this.reset(e);
    }
    if(e.keyCode == 13) {
      e.preventDefault();
      var query = e.target.value;
      this.performQuery(query);
    }
  },
  toggleSort: function(e) {
    e.preventDefault();
    this.setState({showSortMenu: !this.state.showSortMenu});
  },
  sortBy: function(e) {
    e.preventDefault();
    var self = this;
    this.setState({sort: $(e.target).text(), showSortMenu: false}, function() {
      this.performQuery(this.state.query, true, 1);
    });
  },
  performQuery: function(query, force, page) {
    if(!query || query.length == 0) {
      if(this.state.query) history.pushState(null, null, "/search");
      this.setState({query: null, results: null, loading: false});
      return;
    }
    if(!force && query == this.state.query) {
      return;
    }
    if(!page || page < 1) {
      if(this.state.view) page = this.state.view.page;
      else page = 1;
    }
    var data = {query: query, sort: this.state.sort, page: page};
    var self = this;
    this.setState({query: query}, function(e) {
      if(self.search_request)
        window.clearTimeout(self.search_request);
      self.search_request = window.setTimeout(function() {
        Data.action("search", "post", [], data, {error: function() {
          console.log("Search failed.");
        }, success: function(data) {
          var results = [];
          if(page > 1 && self.state && self.state.results) results = self.state.results;
          Array.prototype.push.apply(results, data['results']);
          self.setState({sort: data['sort'], view: data['view'], results: results, loading: false});
          var sortUrl = "";
          if(self.state.sort != "score") {
            sortUrl = "/"+self.state.sort;
          }
          history.pushState(null, null, "/search/"+encodeURIComponent(query)+sortUrl);
        }});
        self.search_request = null;
      }, 500);
    });
  },
  loadMore: function(e) {
    if(this.state.query && this.state.view.page) {
      this.performQuery(this.state.query, true, this.state.view.page + 1);
    }
    e.preventDefault();
  },
  render: function() {
    if(this.state.results && this.state.results.length > 0) {
      var results = this.state.results.map(function(post,i) {
        var user = Data.get("user", post.user_id);
        return  <ChannelPost key={"post-"+post.id} id={post.id} channelId={post.channel_id} user={user} post={post} posts={self} editable={false} />;
      });
      var viewLoader = <ViewLoader callback={this.loadMore} visible={this.state.results.length} octicon="chevron-down" count={this.state.view.count} message={"more results"} />;
    } else if(this.state.loading) {
      var results = "Loading results....";
    } else {
      var results = "No results found.";
    }
    if(this.state.view) {
      var className = "sort-menu search-menu";
      if(this.state.showSortMenu) className += " active";
      var resultHeader = <header className="search-header">
        <span className="result-count">
          Results
          <span className="result-start"> 1 </span>
          -
          <span className="result-end"> {this.state.view.end} </span>
          of
          <span className="result-total"> {this.state.view.count}</span>
        </span>
        <span className="sort-by">
          <span>Sort by: </span>
          <span className={className}>
            <div className="search-menu-options">
              <span className={"option"+(this.state.sort == "score" ? " selected" : "")} onClick={this.sortBy}>score</span>
              <span className={"option"+(this.state.sort == "created" ? " selected" : "")} onClick={this.sortBy}>created</span>
              <span className={"option"+(this.state.sort == "faves" ? " selected" : "")} onClick={this.sortBy}>faves</span>
            </div>
            <span className="title" onClick={this.toggleSort}>{this.state.sort} <span className="octicon octicon-chevron-down" /></span>
          </span>
        </span>
      </header>;
    }
    return <div className="search-results">
      <div className="search-box">
        <input type="search" value={this.state.query} onKeyDown={this.onKeydown} onChange={this.onChange} />
        <button onClick={this.search} className="search-button content-button button-default">Search</button>
        <ChannelPostsSearchHelp />
      </div>
      {resultHeader}
      {results}
      {viewLoader}
    </div>;
  }
});

// module.exports = ChannelPostsSearch;
window.ChannelPostsSearch = ChannelPostsSearch;
