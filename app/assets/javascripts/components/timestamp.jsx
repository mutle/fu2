// var React = require('react');

var timestamps = [];

var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
var formatTimestamp = function(timestamp) {
  var d = new Date(timestamp);
  var today = new Date();
  var t = (today - d);
  t = t / 1000;
  if(t < 60) return t.toFixed()+"s";
  t = (t / 60);
  if(t < 60) return t.toFixed()+"m";
  t = (t / 60);
  if(t < 24) return t.toFixed()+"h";
  t = (t / 24);
  var date = monthNames[d.getMonth()]+" "+d.getDate();
  if(d.getFullYear() != today.getFullYear())
    date += ", "+d.getFullYear();
  return date;
  // if(t < 365) return t.toFixed()+"d";
  // t = (t / 365);
  // return t.toFixed()+"y";
};

var Timestamp = React.createClass({
  componentDidMount: function() {
    this.mounted = true;
    timestamps.push(this);
  },
  componentWillUnmount: function() {
    this.mounted = false;
  },
  componentWillReceiveProps: function() {
    this.lastts = null;
  },
  shouldComponentUpdate: function() {
    if(!this.mounted) return false;
    if(!this.lastts) return true;
    if(this.lastts != formatTimestamp(this.props.timestamp)) return true;
    return false;
  },
  render: function() {
    if(this.props.timestamp === "") return null;
    this.lastts = formatTimestamp(this.props.timestamp);
    return <span className="ts" title={new Date(this.props.timestamp)}>{this.lastts}</span>;
  }
});
// module.exports = Timestamp;
window.Timestamp = Timestamp;

$(function() {
  window.updateTimestamps = function(timestampE) {
    $.each(timestampE, function(i,e) {
     var t = parseInt($(e).data("timestamp")) * 1000;
     var ts = React.render(<Timestamp timestamp={t} />, e);
     timestamps.push(ts);
   });
  }
  var updateTs = function() {
    $.each(timestamps, function(i, ts) {
      if(ts.mounted) ts.setState({});
    });
  }
  window.setInterval(updateTs, 1000);
});
