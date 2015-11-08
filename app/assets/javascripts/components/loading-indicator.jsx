// var React = require('react');

var LoadingIndicator = React.createClass({
  render: function() {
    return <div className="loading-indicator">Loading...</div>;
  }
});

// module.exports = LoadingIndicator;
window.LoadingIndicator = LoadingIndicator;
