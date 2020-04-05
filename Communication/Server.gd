extends Node

const PORT: int = 9081

var server: TCP_Server
var client: StreamPeerTCP


func _ready() -> void:
	server = TCP_Server.new()
	if server.listen(PORT) == OK:  # In gdscript it seems like OK means 0
		set_process(true)
		print("Server started on port %d" % PORT)
	else:
		print("Failed to start server on port %d" % PORT)


func _process(_delta) -> void:
	if server.is_connection_available():
		client = server.take_connection()
		print("Connected to local host server")
	if client and !client.is_connected_to_host():
		print("Client disconnected")
		print("Server listening on port %d" % PORT)
	if client and  client.is_connected_to_host():
		poll_server()


func stop_server() -> void:
	server.stop()


func poll_server() -> void:
	while client.get_available_bytes() > 0:
		var msg = str(client.get_string(client.get_available_bytes()))
		print("Received msg: %s " % msg)

		send_var("Echo: %s " % msg)


func send_var(msg: String) -> void:
	msg = msg + "<EOF>"
	if client.is_connected_to_host():
		print("Sending: %s" % msg)
		client.put_data(msg.to_ascii())



# Bellow is a template is the server needs to serve more than 1 client.

#var server: TCP_Server # for holding your TCP_Server object
#var connection = [] # for holding multiple connection (StreamPeerTCP) objects
#var peerstream = [] # for holding multiple data transfer (PacketPeerStream) objects
#
#func _ready():
#	server = TCP_Server.new()
#	if server.listen(PORT) == 0:
#		print("Server started at port "+str(PORT))
#		set_process(true)
#	else:
#		print("Failed to start server on port "+str(PORT))
#
#func _process(_delta):
#	if server.is_connection_available(): # check if someone's trying to connect
#		var client = server.take_connection() # accept connection
#		connection.append( client ) # we need to save him somewhere, that's why we have our Array
#		peerstream.append( PacketPeerStream.new() ) # also add some data transfer object
#		var index = connection.find( client )
#		peerstream[ index ].set_stream_peer( client )
#		print("Client has connected!");
#
#	for client in connection:
#		print(str(client.get_string(client.get_available_bytes())))
#		if !client.is_connected_to_host():
#			print("Client disconnected "+str(client.get_status()))
#			var index = connection.find( client)
#			connection.remove( index )
#			peerstream.remove( index )
