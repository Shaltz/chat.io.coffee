http = require 'http'
fs = require 'fs'
nodestatic = require 'node-static'


# server = http.createServer (req, res) ->
# 	fs.readFile 'index.html', 'utf8', (error, content) ->
# 		res.writeHead 200, {'Content-Type':'text/html'}
# 		res.end(content)

web = new nodestatic.Server './www'

server = require('http').createServer (request, response)->
	request.addListener('end', -> web.serve request, response).resume();


io = require('socket.io').listen(server)

io.sockets.on 'connection', (socket) ->

	socket.on 'message', (message) ->
		resp =
			content: message
			pseudo: socket.pseudo

		# socket.broadcast.emit 'message', resp # broadcast to all except original sender
		# socket.emit 'messageMoi', resp # emit to original sender only
		io.sockets.emit 'message', resp # emit to EVERYONE

	socket.on 'petit_nouveau', (pseudo) ->
		socket.pseudo = pseudo
		socket.broadcast.emit 'welcome',
			content:' est connecté...'
			pseudo: socket.pseudo

	socket.on 'disconnect', ->
		socket.broadcast.emit 'welcome',
			content:' est parti... :('
			pseudo: socket.pseudo

server.listen 8080
