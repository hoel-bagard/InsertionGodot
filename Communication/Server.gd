extends Node
export(NodePath) var pathToPeg


const PORT: int = 9081

var server: TCP_Server
var client: StreamPeerTCP

var peg: Node
var peg_coord: Array

func _ready() -> void:
	peg = get_node(pathToPeg)

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
	# peg.jump()

func stop_server() -> void:
	server.stop()


func poll_server() -> void:
	while client.get_available_bytes() > 0:
		var msg = str(client.get_string(client.get_available_bytes()))
		# print("Received msg: %s " % msg)
		# send_var("Echo: %s " % msg)

		var json_data = JSON.parse(msg)
		if json_data.error != OK:
			print("Could not parse JSON")
			return
		json_data = json_data.result
		print(json_data)
		if json_data["coord"]:
			peg_coord = peg.move(json_data["coord"])

		# Answer
		# capture screen
		var img = get_viewport().get_texture().get_data()
		# img.save_png("res://screenshot.png")
		img.crop(600, 600)
		img.convert(4)
		img = String(Array(img.get_data()))
		img = Marshalls.variant_to_base64(img)
		# img = Marshalls.raw_to_base64(img)  # img.get_buffer(img.get_len()))
		var data = {
			"action": "FIRST",
			"image": img,
			"coord": peg_coord,
			"done": 0
		}
		send_var(JSON.print(data))


func send_var(msg: String) -> void:
	msg = msg + "<EOF>"
	if client.is_connected_to_host():
		print("Sending: %s" % msg)
		var error := client.put_data(msg.to_ascii())
		if error != 0:
			print("Error on packet put: %s" % error)




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
