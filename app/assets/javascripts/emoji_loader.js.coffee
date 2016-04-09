Emojis = []
Emojis.loaded = false
Emojis.load = (url_root) ->
  $.ajax
    url: url_root+"/api/emojis",
    dataType: "json",
    type: "get",
    success: (data) ->
      window.Emojis.loaded = true
      window.Emojis = data.emojis

window.Emojis = Emojis
