
extends Node

const port = 9081

var server # for holding your TCP_Server object
var connection = [] # for holding multiple connection (StreamPeerTCP) objects
var peerstream = [] # for holding multiple data transfer (PacketPeerStream) objects

func _ready():
	server = TCP_Server.new()
	if server.listen(port) == 0:
		print("Server started at port "+str(port))
		set_process(true)
	else:
		print("Failed to start server on port "+str(port))

func _process(_delta):
	if server.is_connection_available(): # check if someone's trying to connect
		var client = server.take_connection() # accept connection
		connection.append( client ) # we need to save him somewhere, that's why we have our Array
		peerstream.append( PacketPeerStream.new() ) # also add some data transfer object
		var index = connection.find( client )
		peerstream[ index ].set_stream_peer( client )
		print("Client has connected!");
	
	for client in connection:
		print(str(client.get_string(client.get_available_bytes())))
		if !client.is_connected_to_host():
			print("Client disconnected "+str(client.get_status()))
			var index = connection.find( client)
			connection.remove( index )
			peerstream.remove( index )
	
	for peer in peerstream:
		var packet_nb = peer.get_available_packet_count()
		if packet_nb != 0:
			print(packet_nb)
		var msg = peer.get_var() # .size() # .get_string_from_utf8()
		# print(msg)



#extends Node
#
#var PORT: int = 9081
#
#var server: TCP_Server
#var client: StreamPeerTCP
#var wrapped_client: PacketPeerStream
#var connected: bool = false
#var message_center
#var should_connect: bool = true
#
#func _ready() -> void:
#	server = TCP_Server.new()
#	var err := server.listen(PORT)
#	if err == OK:
#		print("Server started on port %d" % PORT)
#	else:
#		print("Could not start server")
#
#
#
#func _process(_delta) -> void:
#	if should_connect and not connected:
#		if server.is_listening() and server.is_connection_available():  #  is_connection_available is probably not needed
#			client = server.take_connection()
#			if client and client.is_connected_to_host():
#				print("Connected to local host server")
#				connected = true
#				# client.set_no_delay(true)
#				wrapped_client = PacketPeerStream.new()
#				wrapped_client.set_stream_peer(client)
#				set_process(true) 
#	elif connected and not client.is_connected_to_host():
#		connected = false
#		set_process(false) # stop listening for packets
#		print("Client disconnected")
#		print("Server listening on port %d" % PORT)
#	elif client.is_connected_to_host():
#		poll_server()
#
#func stop_server() -> void:
#	server.stop()
#
#
#func poll_server() -> void:
#	while wrapped_client.get_available_packet_count() > 0:
#		print("Test2")
#		var msg = wrapped_client.get_var()
#		var error = wrapped_client.get_packet_error()
#		if error != 0:
#			print("Error on packet get: %s" % error)
#		if msg == null:
#			continue;
#		print("Received msg: " + str(msg))
#		message_center.process_msg(str(msg))
#
#
#func send_var(msg: String) -> void:
#	if client.is_connected_to_host():
#		print("Sending: %s" % msg)
#		wrapped_client.put_var(msg)
#		var error = wrapped_client.get_packet_error()
#		if error != 0:
#			print("Error on packet put: %s" % error)
