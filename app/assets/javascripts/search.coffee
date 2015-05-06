# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->

  if $('input#search').length
    autocompleter 'input#search', (term, autocompleter) ->
      q = ""
      q += "title:#{t} " for t in term.split(" ")
      $.getJSON "/search", {"search": q}, (data, status, xhr) ->
        results = []
        for result in data.objects
          item =
            title:result.title,
            url: "/channels/#{result.id}"
          results.push item
        autocompleter.showResults results, term

  if('input#search-field').length

    @offset = 0

    showResults = (query, {offset,sort,append}) ->
      sort ?= "created"
      url = "#{document.location.origin}/search?utf8=✓&search=#{encodeURIComponent(query)}&sort=#{encodeURIComponent(sort)}&start=#{encodeURIComponent(offset)}"
      $.get "#{url}&update=1", (data, status, xhr) ->
        if append
          $("#search-results").append(data)
        else
          $("#search-results").empty().append(data)
        info = $("#search-results .info")
        $(".result-count").empty().html(info.html())
        info.remove()
        $(window).scrollTop(0)
        history.pushState(null, null, url)


    getQuery = -> $("input#search-field").val()
    getOffset = -> parseInt($(".result-count .result-start").text()) - 1
    getNextOffset = -> parseInt($(".result-count .result-end").text())
    getSort = -> $(".sort-by .option.selected").text()

    $(".advanced-search").click ->
      $("#advanced-search").toggleClass("active")

    $(".sort-menu .option").click ->
      m = $(this).parents(".sort-menu")
      m.find(".option").removeClass("selected")
      $(this).addClass("selected")
      m.find(".title").text getSort()
      showResults getQuery(), offset: 0, append: false, sort: getSort()

    $(".search-menu").click ->
      visible = $(this).hasClass("active")
      $(".search-menu").removeClass("active")
      $(this).toggleClass("active") if !visible

    $(".search-menu .option").click ->
      $(this).parents(".search-menu").find(".title").text($(this).text())

    $(".search-more-results").click ->
      showResults getQuery(), offset: getNextOffset(), append: false, sort: getSort()
      false
