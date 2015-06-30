class Socket
  constructor: (@url, @api_key) ->
    @subscriptions = {}
    @available = false
  connected: ->
  connect: ->
    @connection = new WebSocket(@url)
    @connection.onopen = () =>
      @available = true
      @connection.send(JSON.stringify({type: "auth", api_key: @api_key}))
      for type,subscriptions of @subscriptions
        for s in subscriptions
          s.open?()
    @connection.onerror = (error) =>
    @connection.onmessage = (e) =>
      data = $.parseJSON($.parseJSON(e.data))
      return if !@subscriptions[data.type]
      for s in @subscriptions[data.type]
        s.data(data.object)
    @connection.onclose = (e) =>
      @available = false
      @retryconnect()
      for type,subscriptions of @subscriptions
        for s in subscriptions
          s.close?()
  retryconnect: () ->
    c = () => @connect()
    window.setTimeout c, 10 * 1000
  subscribe: (type, callback, opened, closed) ->
    @subscriptions[type] ?= []
    @subscriptions[type].push(data: callback, open: opened, close: closed)
    true

$ ->
  window.socket = new Socket($("body").data("socket-server"), $("body").data("api-key"))
  window.socket.connect()
