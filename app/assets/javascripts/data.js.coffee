class Data
  fetches:
    channels:
      result: "channels"
      type: "channel"
      url: "/channels"
    channel_posts:
      result: "posts"
      type: (data) -> if data.event? then "event" else "post"
      url: "/channels/{id}/posts"
    users:
      type: "user"
  constructor: ->
    @callbacks = {}
    @store = {}
  fetch: (type, id=0) ->
    info = @fetches[type]
    if !info
      console.log("No fetch defined for #{type}.")
      return
    url = info.url.replace(/{id}/, id)
    $.ajax url: url, dataType: "json", type: "get", success: (data) =>
      results = []
      console.log(data)
      for o in data[info.result]
        t = if info.type.call? then info.type(o) else info.type
        @insert t, o.id, o
        results.push [t, o.id, o]
      @notify type, results
  subscribe: (type, callback, object, attributes, id=0) ->
    @callbacks[type] ?= []
    @callbacks[type].push(callback: callback, object: object, id: id, attributes: attributes)
  notify: (type, results) ->
    if !@callbacks[type]
      console.log("No callback defined for #{type}.")
      return
    for callback in @callbacks[type]
      # if id == 0 || id == callback.id
      d = @dataForCallback(callback, results)
      callback.callback.apply(callback.object, [d])
  dataForCallback: (callback, data) -> data
  insert: (type, id, object) ->
    @store[type] ?= []
    @store[type][id] = object
  get: (type, id) ->
    @store[type]?[id]

window.Data = new Data()

$ ->
  $.each window.Users, (i,user) ->
    window.Data.insert("user", user.id, user)
