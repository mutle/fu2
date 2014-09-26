$ ->
  num_hours = 72
  $(".active-channels").on "click", ".body img", ->
    $(this).toggleClass("full")


  $(".active-channels").on "click", ".show", ->
    $(this).parents(".posts").find(".activity-post").removeClass("hide")

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
