$ ->

  mentionStrategy =
    match: /(^|\s)@(\w*)$/,
    search: (term, callback) ->
      regexp = new RegExp('^' + term)
      callback $.grep window.Users, (user) ->
        return regexp.test(user.login)
    replace: (value) ->
      return '$1@' + value + ' '
    template: (user) ->
      return "<img class=\"autocomplete-image\" src=\"#{user.avatar_url}.png\"></img> #{user.login}"

  emojiStrategy =
    match: /(^|\s):(\w*)$/,
    search: (term, callback) ->
      regexp = new RegExp('^' + term)
      callback $.grep window.Emojis, (emoji) ->
        return regexp.test(emoji)
    replace: (value) ->
      return '$1:' + value + ': '
    template: (value) ->
      return "<img class=\"autocomplete-image\" src=\"/images/emoji/#{value}.png\"></img> #{value}"

  completerStrategies = [mentionStrategy, emojiStrategy]


  mobile = $('body').hasClass('mobile')

  syntax = $('#syntax').val()
  if syntax && syntax == "html"
    $('.comment_box').markItUp(mySettings)
  insertText = (text) ->
    if syntax && syntax == "html"
      $.markItUp
        target: $('.comment_box')
        placeHolder: text
    else
      $('.comment_box').append text
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
    autocompleter 'input#search', (term, autocompleter) ->
      $.getJSON "/channels/search", {"search": "title:"+term+""}, (data, status, xhr) ->
        results = []
        for result in data
          item =
            display_title: result.display_title,
            title:result.title,
            url: "/channels/#{result.id}"
          results.push item
        autocompleter.showResults results

  if $('.comment_box').length
    $('.comment_box').textcomplete completerStrategies

  $(document).on 'click', ".fave", ->
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

  $(document).on 'click', ".post-date-link", ->
    self = $(this)
    self.parents(".date-content").find(".post-options").toggle()
    return false

  $(document).on 'click', ".post-reply", ->
    self = $(this)
    post = self.parents(".post").find(".body")
    text = decodeURIComponent(post.attr("data-raw-body"))
    if syntax && syntax == "html"
      text = "<blockquote>#{text}</blockquote>"
    else
      text = text.replace(/</g, '&amp;lt;').replace(/>/g, '&amp;gt;').replace(/(^|\n)/g, "\n> ").replace(/^\n/, '')
    console.log text
    $(".comment-box textarea").focus()
    insertText("#{text}\n\n")
    self.parents(".date-content").find(".post-options").toggle()
    return false

  $(document).on 'click', ".post-unread", ->
    self = $(this)
    post = self.attr("data-prev-post-id")
    ourl = document.location.href.replace(/#.*$/, '')
    url = "#{ourl}/posts/#{post}/unread"
    $.ajax(url:url, dataType: "json", type: "post").done (msg) ->
      self.parents(".date-content").find(".post-options").toggle()
    return false

  refreshPosts = () ->
    last_id = $('.post').last().attr("data-post-id")
    ourl = document.location.href.replace(/#.*$/, '')
    url = "#{ourl}/posts?last_id=#{last_id}"
    $.get url, (data) ->
      $(data).insertBefore('.comment-box-form')

  refreshChannels = () ->
    last_id = $('#recent_acitivities .channel').first().attr("data-last-id")
    url = "/channels/live?last_id=#{last_id}"
    $.get url, (data) ->
      if data.length
        $("#content").empty().append $(data)

  if $('.comment_box').length
    setInterval refreshPosts, 15 * 1000
    $(document).scroll (e) ->
      docViewTop = $(window).scrollTop()
      docViewBottom = docViewTop + $(window).height()
      elemTop = $('.comment_box').offset().top;
      elemBottom = elemTop + $('.comment_box').height()
      if (elemBottom >= docViewTop) && (elemTop <= docViewBottom) && (elemBottom <= docViewBottom) &&  (elemTop >= docViewTop)
        $(".bottom-link .arrow-up").show()
        $(".bottom-link .arrow-down").hide()
      else
        $(".bottom-link .arrow-up").hide()
        $(".bottom-link .arrow-down").show()

  if $('#recent_acitivities.refresh').length
    setInterval refreshChannels, 15 * 1000

  $(".edit-channel-link").click ->
    $(".channel-header").hide()
    $(".channel-header-edit").show()
    return false
  $(".cancel-edit-channel-link").click ->
    $(".channel-header").show()
    $(".channel-header-edit").hide()
    return false
