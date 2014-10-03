$ ->

  mentionStrategy =
    match: /(^|\s)@(\w*)$/,
    search: (term, callback) ->
      regexp = new RegExp('^' + term, 'i')
      callback $.grep window.Users, (user) ->
        return regexp.test(user.login)
    replace: (value) ->
      return '$1@' + value.login + ' '
    template: (user) ->
      return "<img class=\"autocomplete-image\" src=\"#{user.avatar_url}.png\"></img> #{user.login}"

  emojiStrategy =
    match: /(^|\s):(\w*)$/,
    search: (term, callback) ->
      regexp = new RegExp('^' + term, 'i')
      callback $.grep window.Emojis, (emoji) ->
        return regexp.test(emoji)
    replace: (value) ->
      return '$1:' + value + ': '
    template: (value) ->
      return "<img class=\"autocomplete-image\" src=\"/images/emoji/#{value}.png\"></img> #{value}"

  completerStrategies = [mentionStrategy, emojiStrategy]
  mobile = $('body').hasClass('mobile')
  syntax = $('#syntax').val()
  if syntax
    $('.comment_box').textcomplete completerStrategies
    if syntax == "html"
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
      t = $('.comment_box').val()
      t += "\n\n" if t != ''
      t += "![](#{url})"
      $('.comment_box').val(t)
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
        autocompleter.showResults results, term

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
    last_id = $('.post:not(.preview)').last().attr("data-post-id")
    ourl = document.location.href.replace(/#.*$/, '')
    url = "#{ourl}/posts?last_id=#{last_id}"
    $.get url, (data) ->
      $(data).insertBefore('.comment-box-form')
      $(document).trigger 'fu2.refreshPosts'

  refreshChannels = () ->
    last_id = $('#recent_activities .channel').first().attr("data-last-id")
    url = "/channels/live?last_id=#{last_id}"
    $.get url, (data) ->
      if data.length
        $("#content").empty().append $(data)

  previewPost = (contents) ->
    $('<div class="post preview"><div class="name"></div></div>').insertBefore('.comment-box-form')

  removePreviewPost = ->
    $('.post.preview').remove();

  if $('.comment-box-form').length
    setInterval refreshPosts, 15 * 1000
    $('.comment-box-form form').submit ->
      previewPost($('#post_body').val())
      text = $('.comment-box-form textarea').val()
      $('.comment-box-form textarea').val ''
      $.ajax
        type: "POST"
        url: $(this).attr("action")
        data: {"post[body]": text}
        success: (data) ->
          $("#content").append(data.rendered)
          removePreviewPost()
          refreshPosts()
        error: () ->
          removePreviewPost()
          $('.comment-box-form textarea').val text
          $(".upload_info").html("Error sending post. Please try again.")
      false
    $('.comment-box-form textarea').keydown (e) ->
      if e.keyCode == 13 && (e.metaKey || e.ctrlKey)
        $(this).parents('form').submit()

  if $('#recent_activities.refresh').length
    setInterval refreshChannels, 15 * 1000

  $(".bottom-link").click ->
    window.scrollTo 0,document.body.scrollHeight
    return false

  $(".top-link").click ->
    window.scrollTo 0,0
    return false

  $(".edit-channel-link").click ->
    $(".channel-header").hide()
    $(".channel-text").hide()
    $(".no-channel-text").hide()
    $(".channel-header-edit").show()
    return false
  $(".cancel-edit-channel-link").click ->
    $(".channel-header").show()
    $(".channel-text").show()
    $(".no-channel-text").show()
    $(".channel-header-edit").hide()
    return false
