$(document).ready(function() {
  $('.comment_box').markItUp(mySettings);
  
  var cache = {},
  			lastXhr;
  
  if($('input#search').length) {
    $('input#search').autocomplete({
      minLength: 3,
      source: function( request, response ) {
        
        var term = request.term;

        if ( term in cache ) {
          response( cache[ term ] );
          return;
        }

        lastXhr = $.getJSON( "channels/search", {"search": "title:"+term+""}, function( data, status, xhr ) {
          cache[ term ] = data;
          if ( xhr === lastXhr ) {
          	response( data );
          }
        });
      },
      focus: function( event, ui ) {
        var title = ui.item.title;
        $('input#search').val( title );
        return false;
      },
      select: function( event, ui ) {
        window.location = "/channels/"+ui.item.id
        return false;
      }
    })
    .data( "autocomplete" )._renderItem = function( ul, item ) {
      var title = item.display_title; //.replace(/</, "&lt;").replace(/>/, "&gt;");
      return $( "<li></li>" )
      .data( "item.autocomplete", item )
      .append( "<a>" + title + "</a>" )
      .appendTo( ul );
    };

    // Böser Hack, aber da ist n Bug der das immer auf on setzt
    setTimeout("$('input#search').attr('autocomplete', 'off');", 500);

  }

  $(".fave").click(function() {
    var self = $(this);
    var post = self.find(".favorite").attr("data-post-id");
    $.ajax({url:"/posts/"+post+"/fave", dataType: "json", type: "post"}).done(function(msg) {
      self.find(".count").text(""+msg.count);
      var img = self.find('img');
      if(msg.status == true) {
        img.attr("src", img.attr("src").replace('off', 'on'));
      } else {
        img.attr("src", img.attr("src").replace('on', 'off'));
      }
    });
    return false;
  });
});
