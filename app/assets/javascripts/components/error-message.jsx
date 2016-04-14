var ErrorMessage = React.createClass({
  goBack: function(e) {
    e.preventDefault();
    window.history.back();
  },
  render: function() {
    return <div className="error-message">
      <h2>Error: {this.props.title}</h2>
      <div class="info">
        <a href="#" onClick={this.goBack}>Go back</a>
      </div>
    </div>
  }
});

// module.exports = ErrorMessage;
window.ErrorMessage = ErrorMessage;
