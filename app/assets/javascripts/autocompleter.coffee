class Autocompleter
  constructor: (object, callback) ->
    autocompleter = this
    @term = ""
    @callback = callback
    @o = $ object
    @list = $("<ul>").addClass("autocompleter").hide()
    if after = @o.attr("data-after")
      console.log after
      @list.insertAfter $(after)
    else
      @list.insertAfter @o
    @o.keyup (e)->
      key = e.keyCode
      window.console.log key
      if key == 13 # enter
        highlight = autocompleter.list.find("li.highlight a")
        if highlight.size() > 0
          window.location.href = highlight.first().attr "href"
          return false
      else if key == 27 # esc
        autocompleter.removeHighlight()
        return true
      else if key == 38 # up
        if autocompleter.list.find("li.highlight").size() > 0
          autocompleter.setHighlight autocompleter.list.find("li.highlight").removeClass("highlight").prev()
        else
          autocompleter.setHighlight autocompleter.list.find("li").last()
        return false
      else if key == 40 # down
        if autocompleter.list.find("li.highlight").size() > 0
          autocompleter.setHighlight autocompleter.list.find("li.highlight").removeClass("highlight").next()
        else
          autocompleter.setHighlight autocompleter.list.find("li").first()
        return false
      input = $(this).val()
      if input.length >= 2
        autocompleter.query "#{input}" 
      else if input.length == 0
        autocompleter.list.hide()
    @o.blur ->
      window.console.log 'blur'
      autocompleter.list.hide()
    $(".autocompleter li").live "mousedown", ->
      window.location.href = $(this).find("a").attr "href"
    $(".autocompleter li").live "mouseenter", ->
      autocompleter.setHighlight this
    $(".autocompleter li").live "mouseleave", ->
      autocompleter.removeHighlight()
  setHighlight: (e) ->
    @removeHighlight()
    $(e).addClass "highlight"
    @o.val $(e).find("a").attr "data-title"
  removeHighlight: () ->
    @list.find("li.highlight").removeClass "highlight"
    @o.val @term
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
    @list.append $("<li>").html("<a data-title=\"#{r.title}\" href=\"#{r.url}\">#{r.display_title}</a>") for r in results
    @list.show()

autocompleter = (object, callback) ->
  new Autocompleter object, callback

window.autocompleter = autocompleter
