class Socket
  constructor: (@url) ->
    @subscriptions = {}
  connect: ->
    @connection = new WebSocket(@url)
    @connection.onopen = () =>
      @connection.send('Ping')
    @connection.onerror = (error) =>
      console.log("WebSocket Error #{error}")
    @connection.onmessage = (e) =>
      console.log("Message: #{e.data}")
  subscribe: (type, callback) ->
    @subscriptions[type] ?= []
    @subscriptions[type].push callback

$ ->
  window.socket = new Socket($("body").data("socket-server"))
  window.socket.connect()
