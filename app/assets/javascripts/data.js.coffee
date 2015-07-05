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
  constructor: (@socket) ->
    @callbacks = {}
    @store = {}
    @socket.connect()
  fetch: (info, id=0) ->
    return if !info
    url = info.url.replace(/{id}/, id)
    $.ajax url: url, dataType: "json", type: "get", success: (data) =>
      types = []
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
    dataCallback = (data, type) =>
      @insert(data)
      @notify([data.type])
    open = =>
    close = =>
    socket.subscribe info.subscribe, dataCallback, open, close
  subscribe: (type, callback, object, id=0) ->
    @callbacks[type] ?= []
    @callbacks[type].push(callback: callback, object: object, id: id)
  notify: (types) ->
    for type in types
      continue if !@callbacks[type]
      for callback in @callbacks[type]
        # if id == 0 || id == callback.id
        d = @dataForCallback(callback, type)
        console.log d
        callback.callback.apply(callback.object, [d])
  dataForCallback: (callback, type) ->
    @getAll(type).sort (a,b) => a.id - b.id
  insert: (object) ->
    # console.log(object)
    type = object.type
    id = object.id
    @store[type] ?= []
    @store[type][id] = object
    object
  get: (type, id) ->
    @store[type]?[id]
  getAll: (type) ->
    @store[type]
  create: (type, url, props) ->
  destroy: (type, url) ->
  update: (type, url, props) ->

$ ->
  window.socket = new Socket($("body").data("socket-server"), $("body").data("api-key"))
  window.Data = new Data(window.socket)
  $.each window.Users, (i,user) ->
    window.Data.insert(user)
