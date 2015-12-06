var ChannelPostsSearch = React.createClass({
  getInitialState: function() {
    return {page: 1, query: null, results: null, view: null, sort: "score", showSortMenu: false};
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
      this.performQuery(this.state.query, true);
    });
  },
  performQuery: function(query, force) {
    console.log(query);
    if(!query || query.length == 0) {
      if(this.state.query) history.pushState(null, null, "/search");
      this.setState({query: null, results: null});
      return;
    }
    if(!force && query == this.state.query) {
      return;
    }
    var data = {query: query, sort: this.state.sort, page: this.state.page};
    var self = this;
    this.setState({query: query}, function(e) {
      Data.action("search", "post", [], data, {error: function() {
        console.log("Search failed.");
      }, success: function(data) {
        console.log(data);
        self.setState({sort: data['sort'], view: data['view'], results: data['results']});
        history.pushState(null, null, "/search/"+encodeURIComponent(query));
      }});
    });
  },
  render: function() {
    if(this.state.results && this.state.results.length > 0) {
      var results = this.state.results.map(function(post,i) {
        var user = Data.get("user", post.user_id);
        return  <ChannelPost key={"post-"+post.id} id={post.id} channelId={post.channel_id} user={user} post={post} posts={self} editable={false} />;
      });
    } else {
      var results = "No results found.";
    }
    if(this.state.view) {
      var className = "sort-menu search-menu";
      if(this.state.showSortMenu) className += " active";
      var resultHeader = <header className="search-header">
        <span className="result-count">
          Results
          <span className="result-start"> {(this.state.view.page - 1) * this.state.view.per_page + 1} </span>
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
      </header>
    }
    return <div className="search-results">
      <div className="search-box">
        <input type="search" value={this.state.query} onKeyDown={this.onKeydown} onChange={this.onChange} />
        <button onClick={this.search}>Search</button>
      </div>
      {resultHeader}
      {results}
    </div>;
  }
});

// module.exports = ChannelPostsSearch;
window.ChannelPostsSearch = ChannelPostsSearch;
