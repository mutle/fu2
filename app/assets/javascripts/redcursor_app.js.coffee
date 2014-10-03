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
    $('<div class="post-preview"><span class="octicon octicon-hourglass"></span></div>').insertBefore('.comment-box-form')

  removePreviewPost = ->
    $('.post-preview').remove();

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
