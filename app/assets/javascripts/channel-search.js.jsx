var ChannelSearchResult = React.createClass({
  render: function() {
    var url = "/channels/"+this.props.id;
    return <li><a href={url}>{this.props.title}</a></li>;
  }
});

var ChannelSearchResults = React.createClass({
  render: function() {
    var showResult = function(result, index) {
      return <ChannelSearchResult id={result.id} key={result.id} title={result.title} />;
    };
    return <ul className='results'>{this.props.results.map(showResult)}</ul>
  }
});

var ChannelSearch = React.createClass({
  getInitialState: function() {
    return {hidden: true, text: '', results: []};
  },
  handleSubmit: function(e) {
    e.preventDefault();
  },
  onChange: function(e) {
    var query = e.target.value;
    this.setState({text: query});
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
    $.getJSON("/search", {"search": q}, function(data, status, xhr) {
      c.setState({results: data.objects});
    });
  },
  onKeydown: function(e) {
    if(e.key == "Escape") {
      this.setState({hidden: true});
    }
  },
  render: function() {
    var classname = "channel-search";
    if(this.state.hidden) classname += " hidden";
    return <div className={classname}>
      <span className='octicon octicon-search' />
      <form onSubmit={this.handleSubmit}>
        <input className="search-field" onKeyDown={this.onKeydown} onChange={this.onChange} value={this.state.text} />
      </form>

      <ChannelSearchResults results={this.state.results} />
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
