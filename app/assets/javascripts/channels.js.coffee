$ ->
  num_hours = 12

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

  $(document).on 'click', ".post-reply", ->
    self = $(this)
    post = self.parents(".channel-post").find(".body")
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

  $(document).on 'click', '.markdown-help', ->
    $(".markdown-help-show").toggle()
    return false

  if $(".comment-box").length > 0
    # window.scrollLoader = new ScrollLoader($(".post-loader"))
    if window.location.hash != "" && window.location.hash.lastIndexOf("#post_", 0) == 0
      post_id = parseInt(window.location.hash.replace(/^#post_/, ''))
      if $(".post-#{post_id}").length > 0
        $(".post-#{post_id}").addClass("highlight") if !$(".post-#{post_id}").hasClass("unread")
      else
        window.scrollLoader.loadMore post_id, () ->
          window.location.hash = "post_#{post_id}"
          $("body").scrollTop($(".post-#{post_id}").addClass("highlight").offset().top)
  # else if $(".channel-list.refresh").length > 0
    # window.scrollLoader = new ScrollLoader($(".channel-loader"), false)
