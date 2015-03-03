$ ->
  num_hours = 12
  $(".active-channels").on "click", ".body img", ->
    $(this).toggleClass("full")
    false


  $(".active-channels").on "click", ".show", ->
    $(this).parents(".posts").find(".activity-post").removeClass("hide")
    false

  $(".activity-graph-data").each (i,a) ->
    graph = d3.select(a)
    data = $.map $(a).data("sparklines").split(","), (e) -> parseInt(e)
    svg = graph.select(".activity-graph").append("svg:svg").attr("width", "100%").attr("height", "100%")

    x = d3.scale.linear().domain([0, num_hours]).range([0, 60])
    y = d3.scale.linear().domain([0, d3.max(data) + 1]).range([22, 4])

    line = d3.svg.line()
      .x (d,i) ->
        console.log [d,i]
        x(i)
      .y (d) ->
        console.log [d]
        y(d)

    svg.append("svg:path").attr("d", line(data))

    # x = d3.scale.linear().domain([0, 10]).range([0, 50])

  postTemplate = (body, user) ->
    "
<div class=\"activity-post highlight\">
  <img src=\"#{user.avatar_url.replace(/22$/, '32')}\" class=\"avatar\" title=\"#{user.login}\" />
  <div class=\"body\">
    #{body}
  </div>
</div>
    "

  $(document).on 'click', ".post-header .faves .octicon", ->
    self = $(this)
    post = self.parents(".post").attr("data-post-id")
    $.ajax(url:"/posts/"+post+"/fave", dataType: "json", type: "post").done (msg) ->
      self.parents(".faves").toggleClass("active", msg.status).find(".count").text("#{msg.count}")
    return false

  syntax = $('#syntax').val()
  insertText = (text) ->
    if syntax && syntax == "html"
      $.markItUp
        target: $('.comment-box')
        placeHolder: text
    else
      $('.comment-box').append text
  insertImage = (url) ->
    if syntax && syntax == "html"
      $.markItUp
        target: $('.comment-box')
        placeHolder: "<img src=\"#{url}\" />"
    else
      t = $('.comment-box').val()
      t += "\n\n" if t != ''
      t += "![](#{url})"
      $('.comment-box').val(t)

  $(document).on 'click', ".upload-image", ->
    form = $(this).parents("form")
    file = form.find("input[type=file]")
    info = form.find(".info")
    filename = ""

    uploadComplete = (xhr) ->
      console.log xhr.responseText
      info.html("Finished uploading \"#{filename}\"")
      insertImage(JSON.parse(xhr.responseText).url)
    uploadError = (d) ->
      info.html("Error #{d}")
    uploadProgress = (progress) ->
      info.html("Uploading \"#{filename}\" (#{progress}%)")

    startUpload = () ->
      xhr = new XMLHttpRequest()
      xhr.open 'POST', $(form).attr('action'), true
      token = $('meta[name="_csrf"]').attr('content')
      xhr.setRequestHeader('X_CSRF_TOKEN', token)

      xhr.onreadystatechange = (e) =>
        if xhr.readyState == 4
          if xhr.status == 201
            uploadComplete(xhr)
          else if xhr.status == 202
            uploadComplete(xhr)
          else
            uploadError(xhr.responseText)
      xhr.onerror = (e) =>
        uploadError "error"

      if xhr.upload?
        xhr.upload.onprogress = (e) =>
          percentage = Math.round((e.loaded / e.total) * 100)
          uploadProgress(percentage)

      form = new FormData(form[0])
      xhr.send form

    file.on 'change', (e) ->
      f = $(this).val().split("\\")
      filename = f[f.length - 1]
      startUpload()

    file.trigger("click")
    false

  $(document).on 'click', ".post-reply", ->
    self = $(this)
    post = self.parents(".post").find(".body")
    text = decodeURIComponent(post.attr("data-raw-body"))
    if syntax && syntax == "html"
      text = "<blockquote>#{text}</blockquote>"
    else
      text = text.replace(/</g, '&amp;lt;').replace(/>/g, '&amp;gt;').replace(/(^|\n)/g, "\n> ").replace(/^\n/, '')
    $(".comment-box textarea").focus()
    insertText("#{text}\n\n")
    $(".comment-box textarea").focus()
    return false

  $(document).on 'click', ".post-unread", ->
    self = $(this)
    post = self.attr("data-prev-post-id")
    ourl = document.location.href.replace(/#.*$/, '')
    url = "#{ourl}/posts/#{post}/unread"
    $.ajax(url:url, dataType: "json", type: "post")
    return false

  $(".active-channels").on 'click', '.mark-read', ->
    if $(this).hasClass("all-read")
      $(this).removeClass("all-read").parents(".activity").find(".posts").removeClass("hide")
    else
      $(this).addClass("all-read").parents(".activity").find(".posts").addClass("hide").find(".activity-post").removeClass("highlight")
      channelId = parseInt $(this).parents(".activity").data("channel-id")
      $.ajax
        type: "POST"
        dataType: "json"
        url: "/channels/#{channelId}/visit"

  loadMorePosts = (include_id=0, cb=null) ->
    loader = $(".post-loader")
    loader.data("channel-id")
    last_id = $('.post:not(.preview)').first().attr("data-post-id")
    ourl = document.location.href.replace(/#.*$/, '')
    $.get "#{ourl}/posts?first_id=#{last_id}", (data) ->
      $(data).insertAfter loader
      loader.hide()
      cb?()

  $(document).on 'click', ".post-loader a", ->
    loadMorePosts()
    return false

  if window.location.hash != "" && window.location.hash.lastIndexOf("#post_", 0) == 0
    post_id = parseInt(window.location.hash.replace(/^#post_/, ''))
    console.log post_id
    if $(".post-#{post_id}").length < 1
      loadMorePosts post_id, () ->
        $("body").scrollTop($(".post-#{post_id}").offset().top)
        window.location.hash = "post_#{post_id}"

  if $('.comment-small').length
    $('.comment-small').on 'submit', 'form', ->
      textarea = $(this).find('textarea')
      text = textarea.val()
      textarea.val ''
      $.ajax
        type: "POST"
        dataType: "json"
        url: $(this).attr("action")
        data: {"post[body]": text}
        success: (data) ->
          console.log data
          u = $.grep window.Users, (i) -> console.log i ; i.id == data.user_id
          console.log u
          $(postTemplate(data.html_body, u[0])).insertBefore textarea.parents(".comment-small")
          # refreshPosts()
        error: () ->
          textarea.val text
          $(".upload_info").html("Error sending post. Please try again.")
      false
    $('.comment-box').keydown (e) ->
      if e.keyCode == 13 && (e.metaKey || e.ctrlKey)
        $(this).parents('form').submit()
