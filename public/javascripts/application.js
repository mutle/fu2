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

        lastXhr = $.getJSON( "channels/search", {"search": "title:*"+term+"*"}, function( data, status, xhr ) {
          cache[ term ] = data;
          if ( xhr === lastXhr ) {
          	response( data );
          }
        });
      },
      focus: function( event, ui ) {
        var title = ui.item.title.replace(/<\/?strong>/gi, '');
        $('input#search').val( title );
        return false;
      },
      select: function( event, ui ) {
        window.location = "/channels/"+ui.item.id
        return false;
      }
    })
    .data( "autocomplete" )._renderItem = function( ul, item ) {
      var title = item.title.replace(/</, "&lt;").replace(/>/, "&gt;");
      title = title.replace(/&lt;(\/?)strong&gt;/gi, '<$1strong>');
      return $( "<li></li>" )
      .data( "item.autocomplete", item )
      .append( "<a>" + title + "</a>" )
      .appendTo( ul );
    };

    // Böser Hack, aber da ist n Bug der das immer auf on setzt
    setTimeout("$('input#search').attr('autocomplete', 'off');", 500);

  }
});