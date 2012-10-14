app = require('http').createServer handler
io = require('socket.io').listen app
fs = require('fs')

app.listen process.env.PORT || 3001

handler = (req, res) ->
  res.writeHead 200
  res.end "It's alive."

io.sockets.on 'connection', (socket) ->
  socket.emit 'welcome'
