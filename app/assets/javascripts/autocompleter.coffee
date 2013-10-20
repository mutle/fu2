class Autocompleter
  constructor: (object, callback) ->
    autocompleter = this
    @minLength = 2
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
      console.log [input.length, autocompleter.minLength, input]
      if input.length >= autocompleter.minLength
        autocompleter.query "#{input}"
      else if input.length == 0
        autocompleter.list.hide()
    $(document).on "click", ".autocompleter li", ->
      window.location.href = $(this).find("a").attr "href"
      console.log 'click'
    $(document).on "mouseenter", ".autocompleter li", ->
      autocompleter.setHighlight this
    $(document).on "mouseleave", ".autocompleter li", ->
      autocompleter.removeHighlight()
    $(document).on "blur", object, ->
      window.console.log 'blur'
      autocompleter.list.hide()
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
    # @list.css "left", @o.css "left"
    # @list.css "top", @o.css "top"
    # @list.width(@o.width())
    @list.empty()
    @list.append $("<li>").html("<a data-title=\"#{r.title}\" href=\"#{r.url}\">#{r.display_title}</a>") for r in results
    @list.show()

autocompleter = (object, callback) ->
  new Autocompleter object, callback

window.autocompleter = autocompleter
