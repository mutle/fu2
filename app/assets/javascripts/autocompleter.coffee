class Autocompleter
  constructor: (object, callback) ->
    autocompleter = this
    window.console.log 'auto'
    @term = ""
    @callback = callback
    @o = $ object
    @list = $("<ul>").addClass("autocompleter").hide()
    @list.insertAfter @o
    @o.keypress (e)->
      input = $(this).val()
      autocompleter.query "#{input}#{String.fromCharCode e.keyCode}" if input.length >= 2
    @o.blur ->
      window.console.log 'blur'
      autocompleter.list.hide()
    $(".autocompleter li a").live "mousedown", ->
      window.location.href = $(this).attr "href"
    $(".autocompleter li a").live "mouseenter", ->
      autocompleter.o.val $(this).attr "data-title"
    $(".autocompleter li a").live "mouseleave", ->
      autocompleter.o.val @term
  query: (term) ->
    window.console.log "query #{term}"
    @term = term
    @list.hide()
    @callback term, this
  showResults: (results) ->
    if @list.length == 0
      @list.hide()
      return
    @list.css "left", @o.css "left"
    @list.css "top", @o.css "top"
    @list.width(@o.width())
    @list.empty()
    @list.append $("<li>").html("<a data-title='#{r.title}' href='#{r.url}'>#{r.display_title}</a>") for r in results
    @list.show()

autocompleter = (object, callback) ->
  new Autocompleter object, callback

window.autocompleter = autocompleter
