$ ->
  $(".active-channels").on "click", ".body img", ->
    $(this).toggleClass("full")
