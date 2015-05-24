class ScrollLoader
  constructor: (@loader, @addToTop=true) ->
    @hidden = false
    @page = parseInt(@loader.data("loader-page"))
    $(document).on 'scroll', =>
      t = $(document).scrollTop()
      if @addToTop
        if !@hidden && t > 100
          @hidden = true

        if @hidden && t == 0
          @loadMore()
          @hidden = false
      else
        if t >= document.body.scrollHeight - document.body.clientHeight - 5
          if !@hidden
            @loadMore()
            @hidden = true
        else if t >= document.body.scrollHeight - document.body.clientHeight - 100
          @hidden = false


      return false

    @loader.on 'click', "a.load-more", =>
      @loadMore()
      return false

    @loader.on 'click', "a.load-all", =>
      @loadMore(0, null, true)
      return false

  loadMore: (include_id=0, cb=null, all=false) ->
    url = @loader.data("loader-url")
    if @page && @page > 0
      id_attr = "page=#{@page + 1}"
    else
      item = $(@loader.data("loader-items"))
      last_item = if @addToTop then item.first() else item.last()
      last_id = last_item.attr(@loader.data("loader-attr"))
      id_attr = "first_id=#{last_id}"
    limit = ""
    if include_id == 0 && !all
      limit = "&limit=12"
    $.get "#{url}?#{id_attr}#{limit}", (data) =>
      count = $(@loader.data("loader-items")).length
      d = $("<div/>").addClass("loader-group").append $(data)
      if @addToTop
        d.insertAfter @loader
      else
        d.insertBefore @loader
      newcount = $(@loader.data("loader-items")).length - count
      c = @loader.find(".loader-count")
      c.text(parseInt(c.text() - count))
      if parseInt(c.text()) < 1
        @loader.hide()
      cb?()
      @page++ if @page && @page > 0

window.ScrollLoader = ScrollLoader
