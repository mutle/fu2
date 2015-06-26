var ChannelSearchResult = React.createClass({
  render: function() {
    var url = this.props.url ? this.props.url : "/channels/"+this.props.id;
    var selected = "";
    if(this.props.selected) selected = "selected";
    return <li className={selected}><a href={url}>{this.props.title}</a></li>;
  }
});

function searchUrl(query) {
  return document.location.origin + "/search?utf8=✓&search="+encodeURIComponent(query);
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
    return <ul className='results'>
      {defaultResult}
      {this.props.results.map(showResult)}
    </ul>;
  }
});

var ChannelSearch = React.createClass({
  getInitialState: function() {
    return {hidden: true, query: '', cursor: -1, results: []};
  },
  handleSubmit: function(e) {
    e.preventDefault();
  },
  onChange: function(e) {
    var query = e.target.value;
    this.setState({query: query});
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
        console.log(c);
        if(c == -1) {
          document.location.href = searchUrl(this.state.query);
        } else if(c > -1 && this.state.results.length > 0) {
          var channel = this.state.results[c];
          console.log(channel);
          document.location.href = "/channels/"+channel.id;
        }
        break;
    }
  },
  hide: function() {
    this.setState({hidden: true});
  },
  render: function() {
    var classname = "channel-search";
    if(this.state.hidden) classname += " hidden";
    return <div className={classname}>
      <span className='octicon octicon-search' />
      <form onSubmit={this.handleSubmit}>
        <input className="search-field" onBlur={this.hide} onKeyDown={this.onKeydown} onChange={this.onChange} value={this.state.query} />
      </form>

      <ChannelSearchResults query={this.state.query} results={this.state.results} cursor={this.state.cursor} />
    </div>
  }
});

$(function() {
  var search = $(".channel-search-container").get(0);
  var s = React.render(<ChannelSearch />, search);

  $(".show-channel-search").click(function() {
    var hidden = s.state.hidden;
    s.setState({hidden: !hidden});
    if(hidden) $(search).find(".search-field").focus();
  });
})
