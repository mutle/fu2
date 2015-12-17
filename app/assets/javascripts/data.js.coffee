class Socket
  constructor: (@url, @api_key, @site_id) ->
    @subscriptions = {}
    @available = false
    @reconnect = false
  connected: ->
  message: (msg) ->
    @connection.send JSON.stringify(msg) if @available
  connect: ->
    @connection = new WebSocket(@url)
    @connection.onopen = () =>
      if @reconnect
        for type,subscriptions of @subscriptions
          if !type.match(/^offline_/) then continue
          for s in subscriptions
            s.close?()
      @available = true
      @reconnect = true
      @message({type: "auth", api_key: @api_key, site_id: @site_id})
      for type,subscriptions of @subscriptions
        for s in subscriptions
          s.open?()
    @connection.onerror = (error) =>
    @connection.onmessage = (e) =>
      data = $.parseJSON($.parseJSON(e.data))
      return if !@subscriptions[data.type]
      for s in @subscriptions[data.type]
        s.data(data.object, data.type)
    @connection.onclose = (e) =>
      @available = false
      @retryconnect()
      callbacks = []
      for type,subscriptions of @subscriptions
        if !type.match(/^offline_/) then continue
        for s in subscriptions
          s.close?()
  retryconnect: () ->
    c = () => @connect()
    window.setTimeout c, 10 * 1000
  subscribe: (types, callback, opened, closed, object) ->
    for type in types
      @subscriptions[type] ?= []
      @subscriptions[type].push(data: callback, open: opened, close: closed)
    true
  unsubscribe: (types) ->
    for t in types
      @subscriptions[t] = []

class Data
  url:
    channel:
      create: -> "/api/channels.json"
      update: (channel_id) -> "/api/channels/#{channel_id}.json"
    post:
      create: (channel_id) -> "/api/channels/#{channel_id}/posts.json"
      delete: (channel_id, post_id) -> "/api/channels/#{channel_id}/posts/#{post_id}.json"
      update: (channel_id, post_id) -> "/api/channels/#{channel_id}/posts/#{post_id}.json"
      fave: (post_id) -> "/api/posts/#{post_id}/fave.json"
      search: -> "/api/posts/search.json"
      advanced_search: -> "/api/posts/advanced_search.json"
    image:
      create: -> "/api/images.json"
    user:
      update: -> "/api/users.json"
    notification:
      create: -> "/api/notifications.json"
      unread: -> "/api/notifications/unread.json"
      counters: -> "/api/notifications/counters.json"
    sites:
      index: -> "/api/sites.json"
  constructor: (@socket, @user_id, @url_root) ->
    @callbacks = {}
    @store = {}
    @views = {}
    @fetched = {}
    @url_root = @url_root.replace(/^https?:\/\/[^\/]+(\/$)?/, '')
    @url_root = "" if @url_root == "/"
    @socket.connect() if @socket
  fetch: (info, id=0, args={}, fallback=null, errorCallback=null) ->
    return if !info
    if info.view && !info.noCache && !args['last_update']
      cached = @fetched["#{info.view}:#{id}:#{args.page}#{args.first_id}#{args.last_id}"]
      if cached? && cached.length > 0
        @notify(cached)
        return
    url = info.url.replace(/{id}/, id)
    $.ajax
      url: @url_root+url,
      dataType: "json",
      type: "get",
      data: args,
      success: (data) =>
        types = []
        if info.view
          view = info.view.replace(/\$ID/, id)
          @updateView(view, data.view)
        if !info.result
          @insert(data)
          @notify([data.type])
          return
        if info.noCache && info.view
          @store[info.view] = {}
        for rkey, rformat of info.result
          if typeof(rformat) != "string"
            for o in data[rkey]
              t = o.type
              if types.indexOf(t) < 0 then types.push(t)
              @insert(o, t)
          else
            t = data[rkey].type
            if types.indexOf(t) < 0 then types.push(t)
            @insert(data[rkey])
        @notify(types)
        @fetched["#{view}:#{id}:#{args.page}#{args.first_id}#{args.last_id}"] = types if !info.noCache
    dataCallback = (data, type) =>
      @insert(data)
      @notify([data.type])
    socket.subscribe info.subscribe, dataCallback, null, fallback
  subscribe: (type, object, id, callbacks) ->
    @callbacks[type] ?= []
    @callbacks[type].push(callbacks: callbacks, object: object, id: id)
  unsubscribe: (object, types) ->
    for type,c of @callbacks
      remove = []
      for callback in c
        continue if callback.object != object
        remove.push(callback)
      for r in remove
        c = c.splice(c.indexOf(r), 1)
    socket.unsubscribe(types)
  notify: (types) ->
    for type in types
      continue if !@callbacks[type]
      for callback in @callbacks[type]
        d = @dataForCallback(callback, type)
        callback.callbacks.callback.apply(callback.object, [d, @viewInfo(type)])
  dataForCallback: (callback, type) ->
    if callback.id
      [@get(type, callback.id)]
    else
      @getAll(type).sort (a,b) => a.id - b.id
  insert: (object, type=null) ->
    type ?= object.type
    id = object.id
    @store[type] ?= {}
    if !@store[type][id] || !@store[type][id]['updated_at'] || @store[type][id]['updated_at'] <= object['updated_at']
      @store[type][id] = object
    object
  remove: (type, id) ->
    @store[type] ?= {}
    delete @store[type][id]
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
  action: (action, type, url_props, props, {error, success}) ->
    url = @url[type]?[action]?.apply(this, url_props)
    if !url
      console.log "No create URL for #{type}"
      return
    data = {}
    for key,prop of props
      data["#{type}[#{key}]"] = prop
    actionType = "POST"
    actionType = "GET" if action == "index" || action == "show" || action == "advanced_search"
    actionType = "PUT" if action == "update"
    actionType = "DELETE" if action == "delete"
    $.ajax
      type: actionType,
      dataType: "json",
      url: @url_root+url,
      data: data,
      error: error,
      success: success
  destroy: (type) ->
  update: (type, id, props) ->
    @store[type] ?= {}
    @store[type][id] = props
    @notify([type])
$ ->
  window.socket = new Socket($("body").data("socket-server"), $("body").data("api-key"), $("body").data("site-id"))
  window.Data = new Data(window.socket, $("body").data("user-id"), $("body").data("api-root"))
  $.each window.Users, (i,user) ->
    window.Data.insert(user)
