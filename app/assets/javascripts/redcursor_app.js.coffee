$ ->
  mobile = $('body').hasClass('mobile')

  syntax = $('#syntax').val()
  if syntax && syntax == "html"
    $('.comment_box').markItUp(mySettings)
  insertImage = (url) ->
    if syntax && syntax == "html"
      $.markItUp
        target: $('.comment_box')
        placeHolder: "<img src=\"#{url}\" />"
    else
      $('.comment_box').append "![](#{url})"
  $('.comment_box').filedrop
    url: '/images.json'
    paramname: 'image[image_file]'
    allowedfiletypes: ['image/jpeg','image/png','image/gif']
    headers:
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    maxfiles: 1
    maxfilesize: 2
    uploadStarted: (i, file, len) ->
      $(".upload_info").html('Uploading "'+file.name+'"')
    uploadFinished: (i, file, response, time) ->
      $(".upload_info").html('Finished uploading "'+file.name+'"')
      insertImage(response.url)
    progressUpdated: (i, file, progress) ->
      $(".upload_info").html('Uploading "'+file.name+'" ('+progress+"%)")

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
  
  # if $('.comment_box').length
  #   $('.comment_box a').click ->
  #     return false
  #   a = autocompleter $('.comment_box'), (term, autocompleter) ->
  #     word = term.match /(\S+)$/
  #     if word then input = word[1] else return
  #     results = []
  #     if input[0] == ':'
  #       for emoji in window.Emojis
  #         continue if emoji.indexOf(input.substring(1)) == -1 
  #         item = 
  #           display_title: "<img src='/images/emoji/#{emoji}.png' /> :#{emoji}:",
  #           title: ":#{emoji}:"
  #         results.push item
  #       autocompleter.showResults results
  #       pos = $('.comment_box').getCaretPosition()
  #       autocompleter.list.css
  #         left: pos.left
  #         top: pos.top + 40
  #     # else if input[0] == '@'
  #   a.minLength = 1


  $(".fave").live 'click', ->
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

  refreshPosts = () ->
    last_id = $('.post').last().attr("id").replace(/^post_/, ''.replace(/^post_/, ''))
    ourl = document.location.href.replace(/#.*$/, '')
    url = "#{ourl}/posts?last_id=#{last_id}"
    $.get url, (data) ->
      $(data).insertBefore('.comment-box-form')

  if $('.comment_box').length
    setInterval refreshPosts, 15 * 1000

  $(".edit-channel-link").click ->
    $(".channel-header").hide()
    $(".channel-header-edit").show()
    return false
  $(".cancel-edit-channel-link").click ->
    $(".channel-header").show()
    $(".channel-header-edit").hide()
    return false
