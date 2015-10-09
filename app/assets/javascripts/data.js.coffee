class Socket
  constructor: (@url, @api_key) ->
    @subscriptions = {}
    @available = false
  connected: ->
  message: (msg) ->
    @connection.send JSON.stringify(msg) if @available
  connect: ->
    @connection = new WebSocket(@url)
    @connection.onopen = () =>
      @available = true
      @message({type: "auth", api_key: @api_key})
      for type,subscriptions of @subscriptions
        for s in subscriptions
          s.open?()
    @connection.onerror = (error) =>
    @connection.onmessage = (e) =>
      data = $.parseJSON($.parseJSON(e.data))
      console.log(data)
      return if !@subscriptions[data.type]
      for s in @subscriptions[data.type]
        s.data(data.object, data.type)
    @connection.onclose = (e) =>
      @available = false
      @retryconnect()
      for type,subscriptions of @subscriptions
        for s in subscriptions
          s.close?()
  retryconnect: () ->
    c = () => @connect()
    window.setTimeout c, 10 * 1000
  subscribe: (types, callback, opened, closed) ->
    for type in types
      @subscriptions[type] ?= []
      @subscriptions[type].push(data: callback, open: opened, close: closed)
    true

class Data
  url:
    channels:
      create: -> "/api/channels.json"
      update: (channel_id) -> "/api/channels/#{channel_id}.json"
    post:
      create: (channel_id) -> "/api/channels/#{channel_id}/posts.json"
      update: (post_id) -> "/api/posts/#{post_id}.json"
      fave: (post_id) -> "/api/posts/#{post_id}/fave.json"
    image:
      create: -> "/api/images.json"
    notification:
      create: -> "/api/notifications.json"
      unread: -> "/api/notifications/unread.json"
      counters: -> "/api/notifications/counters.json"
  constructor: (@socket) ->
    @callbacks = {}
    @store = {}
    @views = {}
    @fetched = {}
    @socket.connect() if @socket
  fetch: (info, id=0, args={}) ->
    return if !info
    if info.view
      cached = @fetched[info.view+":"+id]
      if cached?
        @notify(cached)
        return
    url = info.url.replace(/{id}/, id)
    $.ajax url: url, dataType: "json", type: "get", data: args, success: (data) =>
      types = []
      if info.view
        @updateView(info.view, data.view)
      for rkey, rformat of info.result
        if typeof(rformat) != "string"
          for o in data[rkey]
            t = o.type
            if types.indexOf(t) < 0 then types.push(t)
            @insert(o)
        else
          t = data[rkey].type
          if types.indexOf(t) < 0 then types.push(t)
          @insert(data[rkey])
      @notify(types)
      @fetched[info.view+":"+id] = types
    dataCallback = (data, type) =>
      @insert(data)
      @notify([data.type])
    open = =>
    close = =>
    socket.subscribe info.subscribe, dataCallback, open, close
  subscribe: (type, object, id, callbacks) ->
    @callbacks[type] ?= []
    @callbacks[type].push(callbacks: callbacks, object: object, id: id)
  unsubscribe: (object) ->
    for type,c of @callbacks
      remove = []
      for callback in c
        continue if callback.object != object
        remove.push(callback)
      for r in remove
        c = c.splice(c.indexOf(r), 1)
  notify: (types) ->
    for type in types
      continue if !@callbacks[type]
      for callback in @callbacks[type]
        d = @dataForCallback(callback, type)
        console.log callback
        callback.callbacks.callback.apply(callback.object, [d, @viewInfo(type)])
  dataForCallback: (callback, type) ->
    if callback.id
      console.log callback
      console.log @getAll(type)
      [@get(type, callback.id)]
    else
      @getAll(type).sort (a,b) => a.id - b.id
  insert: (object) ->
    type = object.type
    id = object.id
    @store[type] ?= {}
    @store[type][id] = object
    object
  updateView: (type, view) ->
    v = @views[type]
    if v
      view.end = v.end if v.end > view.end
      view.start = v.start if v.start < view.start
      view.end_id = v.end_id if v.end_id > view.end_id
      view.start_id = v.start_id if v.start_id < view.start_id
    @views[type] = view
  viewInfo: (type) ->
    @views[type]
  get: (type, id) ->
    @store[type]?[id]
  getAll: (type) ->
    a = []
    a.push(v) for k,v of @store[type]
    a
  create: (type, url_props, props, {error, success}) ->
    url = @url[type]?["create"]?.apply(this, url_props)
    if !url
      console.log "No create URL for #{type}"
      return
    data = {}
    for key,prop of props
      data["#{type}[#{key}]"] = prop
    $.ajax
      type: "POST",
      dataType: "json",
      url: url,
      data: data,
      error: error,
      success: success
  destroy: (type) ->
  update: (type, id, props) ->
    @store[type][id]
    @notify([type])
$ ->
  window.socket = new Socket($("body").data("socket-server"), $("body").data("api-key"))
  window.Data = new Data(window.socket)
  $.each window.Users, (i,user) ->
    window.Data.insert(user)
