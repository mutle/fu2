var AutoCompleterResult = React.createClass({
  render: function() {
    var className = "result "+ (this.props.highlight ? "highlight" : "");
    var title = this.props.value.login ? this.props.value.login : this.props.value;
    var image = this.props.imageUrl ? this.props.imageUrl(this.props.value) : this.props.value.image ? this.props.value.image : null;
    return <li className={className} onClick={this.props.clickCallback} data-value={title}><img src={image} />{title}</li>;
  }
});

var AutoCompleter = React.createClass({
  componentDidMount: function() {
    if(this.props.mountCallback) {
      this.props.mountCallback(this);
    }
  },
  render: function() {
    var input = this.props.input;
    var selection = this.props.selection;
    var imageUrl = this.props.imageUrl;
    var clickCallback = this.props.clickCallback;
    var n = 0;
    var results = this.props.objects.map(function(r, i) {
      var s = r;
      if(r.login) {
        s = r.login;
        imageUrl = function() { return r.avatar_url; };
      }
      var highlight = selection == i;
      return <AutoCompleterResult key={s} value={r} highlight={highlight} imageUrl={imageUrl} clickCallback={clickCallback} />;
    })
    return <ul className="autocompleter">
      {results}
    </ul>;
  }
});

// module.exports = AutoCompleter;
window.AutoCompleter = AutoCompleter;
