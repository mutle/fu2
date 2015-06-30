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

$ ->
  window.socket = new Socket($("body").data("socket-server"), $("body").data("api-key"))
  window.socket.connect()
