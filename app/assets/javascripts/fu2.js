$(document).ready(function() {
  $('.comment_box').markItUp(mySettings);
  
  if($('input#search').length) {
    autocompleter($('input#search'), function(term, autocompleter) {
      $.getJSON( "channels/search", {"search": "title:"+term+""}, function( data, status, xhr ) {
        var results = [];
        for(r in data) {
          var result = data[r];
          var item = {display_title: result.display_title, title:result.title, url: '/channels/'+result.id};
          results.push(item);
        }
        autocompleter.showResults(results);
      });
    });
  }

  $(".fave").click(function() {
    var self = $(this);
    var post = self.find(".favorite").attr("data-post-id");
    $.ajax({url:"/posts/"+post+"/fave", dataType: "json", type: "post"}).done(function(msg) {
      self.find(".count").text(""+msg.count);
      self.find('img').hide();
      if(msg.status == true) {
        self.find(".on").show();
      } else {
        self.find(".off").show();
      }
    });
    return false;
  });
});
