# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->

  if $('input#search').length
    autocompleter 'input#search', (term, autocompleter) ->
      $.getJSON "/search", {"search": "title:"+term+""}, (data, status, xhr) ->
        results = []
        for result in data.objects
          item =
            title:result.title,
            url: "/channels/#{result.id}"
          results.push item
        autocompleter.showResults results, term

  $(".advanced-search").click ->
    $("#advanced-search").toggleClass("active")

  $(".search-menu").click ->
    visible = $(this).hasClass("active")
    $(".search-menu").removeClass("active")
    $(this).toggleClass("active") if !visible

  $(".search-menu .option").click ->
    $(this).parents(".search-menu").find(".title").text($(this).text())
