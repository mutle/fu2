class Socket
  constructor: (@url, @api_key) ->
    @subscriptions = {}
    @available = false
  connect: ->
    @connection = new WebSocket(@url)
    @connection.onopen = () =>
      @available = true
      @connection.send(JSON.stringify({type: "auth", api_key: @api_key}))
    @connection.onerror = (error) =>
      console.log("WebSocket Error #{error}")
    @connection.onmessage = (e) =>
      console.log(e)
      console.log(e.data)
      data = $.parseJSON($.parseJSON(e.data))
      return if !@subscriptions[data.type]
      for s in @subscriptions[data.type]
        s(data.object)
  subscribe: (type, callback) ->
    @subscriptions[type] ?= []
    @subscriptions[type].push callback
    true

$ ->
  window.socket = new Socket($("body").data("socket-server"), $("body").data("api-key"))
  window.socket.connect()
