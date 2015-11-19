// var React = require('react');

var ChannelSearchResult = React.createClass({
  render: function() {
    var url = this.props.url ? this.props.url : Data.url_root + "/channels/"+this.props.id+"#comments";
    var selected = "";
    if(this.props.selected) selected = "selected";
    return <li className={selected}><a href={url}>{this.props.title}</a></li>;
  }
});

function searchUrl(query) {
  return Data.url_root + "/search?utf8=✓&search="+encodeURIComponent(query);
}

var ChannelSearchResults = React.createClass({
  render: function() {
    var selection = this.props.cursor;
    var selectedDefault = selection == -1;
    var searchTitle = <span>Search for <em>{this.props.query}</em></span>;
    var defaultResult = null;
    if(this.props.query.length > 0)
      defaultResult = <ChannelSearchResult url={searchUrl(this.props.query)} selected={selectedDefault} title={searchTitle} />
    var showResult = function(result, index) {
      var selected = index == selection;
      return <ChannelSearchResult id={result.id} key={result.id} title={result.title} selected={selected} />;
    };
    return <div className='results-container'>
      <ul className='results'>
        {defaultResult}
        {this.props.results.map(showResult)}
      </ul>
    </div>;
  }
});

var ChannelSearch = React.createClass({
  getInitialState: function() {
    return {hidden: true, query: '', cursor: -1, results: [], n: -1};
  },
  handleSubmit: function(e) {
    e.preventDefault();
  },
  onChange: function(e) {
    var query = e.target.value;
    var n = this.state.n + 1;
    this.setState({query: query, n: n});
    if(query.length < 2) {
      this.setState({results: []});
      return;
    }
    var q = "";
    var seg = query.split(" ");
    for(var k in seg) {
      var t = seg[k];
      q += "title:"+t+" ";
    }
    var c = this;
    $.getJSON("/search", {"search": q, "per_page": 50}, function(data, status, xhr) {
      if(c.state.n != n) return;
      c.setState({results: data.objects});
    });
  },
  onKeydown: function(e) {
    switch (e.key) {
      case "Escape":
        this.hide();
        break;
      case "ArrowUp":
        var c = this.state.cursor;
        c--;
        if(c < -1) c = -1;
        this.setState({cursor: c});
        break;
      case "ArrowDown":
        var c = this.state.cursor;
        c++;
        if(c >= this.state.results.length) c = this.state.results.length - 1;
        this.setState({cursor: c});
        break;
      case "Enter":
        var c = this.state.cursor;
        if(c == -1) {
          document.location.href = searchUrl(this.state.query);
        } else if(c > -1 && this.state.results.length > 0) {
          var channel = this.state.results[c];
          document.location.href = "/channels/"+channel.id+"#comments";
        }
        break;
    }
  },
  hide: function() {
    this.setState({hidden: true});
  },
  blur: function() {
    var c = this;
    window.setTimeout(function() {
      c.hide();
    }, 300);
  },
  render: function() {
    if(this.state.hidden) return null;
    return <div className="channel-search">
      <span className='octicon octicon-search' />
      <form onSubmit={this.handleSubmit}>
        <input className="search-field" onBlur={this.blur} onKeyDown={this.onKeydown} onChange={this.onChange} value={this.state.query} />
      </form>

      <ChannelSearchResults query={this.state.query} results={this.state.results} cursor={this.state.cursor} />
    </div>;
  }
});

$(function() {
  var search = $(".channel-search-container").get(0);
  if(search != null) {
    var s = React.render(<ChannelSearch />, search);
  }

  $(".toolbar-channel-search").click(function() {
    var hidden = s.state.hidden;
    s.setState({hidden: !hidden});
    if(hidden) $(search).find(".search-field").select().focus();
  });
})


// module.exports = ChannelSearch;
window.ChannelSearch = ChannelSearch;
