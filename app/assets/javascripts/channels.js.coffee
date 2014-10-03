$ ->
  num_hours = 12
  $(".active-channels").on "click", ".body img", ->
    $(this).toggleClass("full")
    false


  $(".active-channels").on "click", ".show", ->
    $(this).parents(".posts").find(".activity-post").removeClass("hide")
    false

  $(".active-channels .activity").each (i,a) ->
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
    $('.comment-box-form textarea').keydown (e) ->
      if e.keyCode == 13 && (e.metaKey || e.ctrlKey)
        $(this).parents('form').submit()
