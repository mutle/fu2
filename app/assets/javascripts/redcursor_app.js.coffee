$ ->
  if $('input#search').length
    autocompleter $('input#search'), (term, autocompleter) ->
      $.getJSON "/channels/search", {"search": "title:"+term+""}, (data, status, xhr) ->
        results = []
        for result in data
          item =
            display_title: result.display_title,
            title:result.title,
            url: "/channels/#{result.id}"
          results.push item
        autocompleter.showResults results

  $(".fave").click ->
    self = $(this)
    post = self.find(".favorite").attr("data-post-id")
    $.ajax(url:"/posts/"+post+"/fave", dataType: "json", type: "post").done (msg) ->
      self.find(".count").text("#{msg.count}")
      self.find('img').hide()
      if msg.status == true
        self.find(".on").show()
      else
        self.find(".off").show()
    return false

  $("#title").click ->
    if $(this).hasClass("active")
      $(".toolbar").removeClass("active")
      $(".title-toolbar").removeClass("active")
      $(this).removeClass("active")
    else
      $(".toolbar").addClass("active")
      $(".title-toolbar").addClass("active")
      $(this).addClass("active")
      $(".toolbar input.search-field").focus()
