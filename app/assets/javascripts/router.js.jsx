$(function() {
  var e = $(".content-inner");
  console.log(document.location.pathname)

  var m = document.location.pathname.match(/^\/channels\/([0-9]+)\/?$/)
  if(m && m[1]) {
    var channel_id = parseInt(m[1])
    var posts = React.render(<ChannelPosts channelId={channel_id} />, e.get(0))
  }

  m = document.location.pathname.match(/^\/(channels)?\/?$/)
  if(m) {
    var channels = React.render(<ChannelList />, e.get(0))
  }

});
