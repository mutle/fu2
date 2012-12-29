$(document).ready(function() {
  var syntax = $('#syntax').val();
  if(syntax && syntax == "html") {
    $('.comment_box').markItUp(mySettings);
  }
  function insertImage(url) {
    if(syntax && syntax == "html") {
      $.markItUp({target:$('.comment_box'), placeHolder: '<img src="'+url+'" />'});
    } else {
      $('.comment_box').append("![]("+url+")");
    }
  }
  $('.comment_box_container').filedrop({
    url: '/images',
    paramname: 'image[image_file]',
    allowedfiletypes: ['image/jpeg','image/png','image/gif'],
    headers: {
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    },
    maxfiles: 1,
    maxfilesize: 2,
    uploadStarted: function(i, file, len){
      $(".upload_info").html('Uploading "'+file.name+'"');
    },
    uploadFinished: function(i, file, response, time) {
      $(".upload_info").html('Finished uploading "'+file.name+'"');
      insertImage(response.url);
    },
    progressUpdated: function(i, file, progress) {
      $(".upload_info").html('Uploading "'+file.name+'" ('+progress+"%)");
    }
  });
  
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
