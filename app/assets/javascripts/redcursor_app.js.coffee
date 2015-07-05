$ ->

  window.formatTimestamp = (timestamp) ->
    d = new Date(timestamp)
    today = new Date()
    t = (today - d)
    t = t / 1000;
    if t < 60 then return t.toFixed()+"s";
    t = (t / 60);
    if t < 60 then return t.toFixed()+"m";
    t = (t / 60);
    if t < 24 then return t.toFixed()+"h";
    t = (t / 24);
    if t < 365 then return t.toFixed()+"d";
    t = (t / 365);
    return t.toFixed()+"y";

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

  postRefreshSocket = false
  refreshPosts = (force) ->
    return
    return if !force && postRefreshSocket
    last_id = $('.channel-post:not(.preview)').last().attr("data-post-id")
    last_update = $(".channel-title").attr("data-last-update")
    ourl = document.location.href.replace(/#.*$/, '')
    url = "#{ourl}/posts?last_id=#{last_id}&last_update=#{last_update}"
    $.get url, (data) ->
      d = $(data)
      d.find(".updated").remove()
      $(".channel-posts").append(d)
      window.updateTimestamps d.find(".update-ts")
      $(".updated .channel-post").each (i, post) ->
        $($(".post-#{$(post).attr("data-post-id")}").get(0)).replaceWith(post)
      last_updated = $(".updated").attr("data-last-update")
      $(".channel-title").attr("data-last-update", last_updated)
      $(".updated").remove()
      $(document).trigger 'fu2.refreshPosts'

  channelRefreshSocket = false
  refreshChannels = (force) ->
    return if !force && channelRefreshSocket
    last_id = $('.channel-list .channel').first().attr("data-last-id")
    url = "/channels/live?last_id=#{last_id}"
    $.get url, (data) ->
      if data.length
        d = $(data)
        window.updateTimestamps d.find(".update-ts")
        $("#content .channel-list.refresh .loader-group:first-child").empty().append d

  if $('.channel-response form.channel-comment').length
    channel_id = parseInt document.location.href.replace(/#.*$/, '').replace(/^.*\/([0-9]+)$/, "$1")
    data = (data, type) ->
      console.log(data.channel_id)
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
    $(document).on 'keydown', '.comment-box-form textarea', (e) ->
      if e.keyCode == 13 && (e.metaKey || e.ctrlKey)
        $(this).parents('form').submit()

  if $('.channel-list.refresh').length
    data = (data, type) -> refreshChannels(true)
    open = ->
      channelRefreshSocket = true
      # refreshChannels(true)
    close = ->
      channelRefreshSocket = false
      c = ->
        refreshChannels()
        setTimeout c, 15 * 1000 if !channelRefreshSocket
      setTimeout c, 15 * 1000
    window.socket.subscribe ["post_create", "channel_create", "post_read"], data, open, close

  $(document).on 'click', '.toolbar-more-link', ->
    $(".more").toggleClass("show")

  $(document).on 'scroll', ->
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

  $(".edit-channel-link").click ->
    $(".channel-text form").show()
    $(".channel-text .text-body").hide()
    $("h2.channel-title").hide()
    return false
  $(".cancel-edit-channel-link").click ->
    $(".channel-text form").hide()
    $(".channel-text .text-body").show()
    $("h2.channel-title").show()
    return false
