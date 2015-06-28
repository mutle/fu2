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
      data = $.parseJSON(e.data)
      console.log(data)
  subscribe: (type, callback) ->
    @subscriptions[type] ?= []
    @subscriptions[type].push callback

$ ->
  window.socket = new Socket($("body").data("socket-server"), $("body").data("api-key"))
  window.socket.connect()
