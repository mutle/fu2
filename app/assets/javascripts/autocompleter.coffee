class Autocompleter

  constructor: (object, callback) ->
    autocompleter = this
    @minLength = 2
    @term = ""
    @callback = callback
    @o = $ object
    @list = $("<ul>").addClass("autocompleter").hide()
    if after = @o.attr("data-after")
      @list.insertAfter $(after)
    else
      @list.insertAfter @o
    @o.keydown (e)->
      key = e.keyCode
      if key == 38 # up
        highlightedElement = autocompleter.list.find("li.highlight")
        if highlightedElement.size() == 0 || highlightedElement.is ':first-child'
          autocompleter.setHighlight autocompleter.list.find("li").last()
        else
          autocompleter.setHighlight autocompleter.list.find("li.highlight").removeClass("highlight").prev()
        return false
      else if key == 40 # down
        highlightedElement = autocompleter.list.find("li.highlight")
        if highlightedElement.size() == 0
          autocompleter.setHighlight autocompleter.list.find("li").eq(1)
        else if highlightedElement.is ':last-child'
          autocompleter.list.find("li.highlight").removeClass("highlight")
          autocompleter.setHighlight autocompleter.list.find("li:first-child")
        else
          autocompleter.setHighlight autocompleter.list.find("li.highlight").removeClass("highlight").next()
        return false
      else if key == 13 # enter
        highlight = autocompleter.list.find("li.highlight a")
        if highlight.size() > 0
          window.location.href = highlight.first().attr "href"
          return false

    @o.keyup (e)->
      key = e.keyCode
      if key == 38 || key == 40 # up or down
        return false
      else if key == 27 # esc
        autocompleter.list.hide()
        return true
      input = $(this).val()
      if input.length >= autocompleter.minLength
        autocompleter.query "#{input}"
      else if input.length == 0
        autocompleter.list.hide()
    $(document).on "blur", object, ->
      autocompleter.list.hide()
    $(document).on "mousedown", ".autocompleter li", ->
      window.location.href = $(this).find("a").attr "href"
    $(document).on "mouseenter", ".autocompleter li", ->
      autocompleter.setHighlight this
    $(document).on "mouseleave", ".autocompleter li", ->
      autocompleter.removeHighlight()

  setHighlight: (e) ->
    @removeHighlight()
    $(e).addClass "highlight"
    #@o.val $(e).find("a").attr "data-title"

  removeHighlight: () ->
    @list.find("li.highlight").removeClass "highlight"
    #@o.val @term

  query: (term) ->
    @term = term
    @list.hide()
    @callback term, this

  showResults: (results, search) ->
    if @list.length == 0
      @list.hide()
      return
    # @list.css "left", @o.css "left"
    # @list.css "top", @o.css "top"
    # @list.width(@o.width())
    @list.empty()
    @list.append $("<li>").html("<a data-is-link-to-full-search href=\"/channels/search?utf8=✓&search=#{search}\">Search for <em>#{search}</em></a>")
    @list.append $("<li>").html("<a data-title=\"#{r.title}\" href=\"#{r.url}\">#{r.display_title}</a>") for r in results
    @list.show()
    this.setHighlight this.list.find("li").eq(1)

autocompleter = (object, callback) ->
  new Autocompleter object, callback

window.autocompleter = autocompleter
