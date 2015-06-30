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
    $('.comment-box').textcomplete completerStrategies
    if syntax == "html"
      $('.comment-box').markItUp(mySettings)

  postRefreshSocket = false
  refreshPosts = (force) ->
    return if !force && postRefreshSocket
    last_id = $('.post:not(.preview)').last().attr("data-post-id")
    last_update = $(".channel-header").attr("data-last-update")
    ourl = document.location.href.replace(/#.*$/, '')
    url = "#{ourl}/posts?last_id=#{last_id}&last_update=#{last_update}"
    $.get url, (data) ->
      d = $(data)
      d.find(".updated").remove()
      d.insertBefore('.comment-box-form')
      $(".updated .post").each (i, post) ->
        $($(".post-#{$(post).attr("data-post-id")}").get(0)).replaceWith(post)
      last_updated = $(".updated").attr("data-last-update")
      $(".channel-header").attr("data-last-update", last_updated)
      $(".updated").remove()
      $(document).trigger 'fu2.refreshPosts'

  channelRefreshSocket = false
  refreshChannels = (force) ->
    return if !force && channelRefreshSocket
    last_id = $('#recent_activities .channel').first().attr("data-last-id")
    url = "/channels/live?last_id=#{last_id}"
    $.get url, (data) ->
      if data.length
        $("#content #recent_activities .loader-group:first-child").empty().append $(data)

  previewPost = (contents) ->
    $('<div class="post-preview"><span class="octicon octicon-hourglass"></span></div>').insertBefore('.comment-box-form')

  removePreviewPost = ->
    $('.post-preview').remove();

  if $('.comment-box-form').length
    channel_id = parseInt document.location.href.replace(/#.*$/, '').replace(/^.*\/([0-9]+)$/, "$1")
    data = (data, type) ->
      if data.channel_id == channel_id
        refreshPosts(true)
    open = ->
      postRefreshSocket = true
      refreshPosts(true)
    close = ->
      postRefreshSocket = false
      c = ->
        refreshPosts()
        setTimeout c, 15 * 1000 if !postRefreshSocket
      setTimeout c, 15 * 1000
    window.socket.subscribe ["post_create"], data, open, close
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
    data = (data, type) -> refreshChannels(true)
    open = ->
      channelRefreshSocket = true
      refreshChannels(true)
    close = ->
      channelRefreshSocket = false
      c = ->
        refreshChannels()
        setTimeout c, 15 * 1000 if !channelRefreshSocket
      setTimeout c, 15 * 1000
    window.socket.subscribe ["post_create", "channel_create"], data, open, close

  $(document).on 'scroll', ->
    $(".bottom-link").css("top", "#{document.body.scrollTop + 6}px")
    $(".bottom-link").toggleClass("top", document.body.scrollTop < 32)
    if document.body.scrollTop < document.body.scrollHeight - document.body.clientHeight
      $(".bottom-link .octicon").removeClass("octicon-arrow-up").addClass("octicon-arrow-down")
    else
      $(".bottom-link .octicon").removeClass("octicon-arrow-down").addClass("octicon-arrow-up")

  $(".bottom-link").click ->
    if $(this).find(".octicon").hasClass("octicon-arrow-up")
      window.scrollTo 0,0
    else
      window.scrollTo 0,document.body.scrollHeight
    return false

  $(".bottom-link").addClass("top")

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
