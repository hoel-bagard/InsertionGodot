extends Node
export(NodePath) var pathToPeg
export(NodePath) var pathToGoal


const PORT: int = 9081

var server: TCP_Server
var client: StreamPeerTCP

var answer_json: Dictionary
var answer_msg: String

var peg: Node
var peg_coord: Array
var goal: Node
const USE_IMG: bool = true
var img: String


func _ready() -> void:
	peg = get_node(pathToPeg)
	goal = get_node(pathToGoal)

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

func poll_server() -> void:
	while client.get_available_bytes() > 0:
		var msg = str(client.get_string(client.get_available_bytes()))
		# print("Received msg: %s " % msg)

		var json_data = JSON.parse(msg)
		if json_data.error != OK:
			print("Could not parse JSON")
			return
		json_data = json_data.result
		# print(json_data)

		# Answer
		if json_data["action"] == "FIRST":
			peg.reset()
			goal.set_done(false)
			answer_msg = JSON.print(self._first_answer())
		elif json_data["action"] == "STEP":
			peg.move(json_data["coord"])
			answer_msg = JSON.print(self._step_answer())
		elif json_data["action"] == "RESET":
			peg.reset()
			goal.set_done(false)
			answer_msg = JSON.print(self._reset_answer())
		elif json_data["action"] == "CLOSE":
			pass

		send_var(answer_msg)

func _get_screenshot(save_img: bool = false) -> String:
	# capture screen
	var img_raw: Image = get_viewport().get_texture().get_data()
	if save_img:
		var error = img_raw.save_png("res://screenshot.png")
	# img_raw.crop(64, 64)
	img_raw.convert(4)
	img = String(Array(img_raw.get_data()))
	img = Marshalls.variant_to_base64(img)
	return img

func _first_answer() -> Dictionary:
	answer_json = {
		"action": "FIRST",
		"coord": goal.get_coord(),            # current position and orientation of the goal
		"image": self._get_screenshot(),      # shoud be the goal image, i.e., image of the connector succesfully inserted.
		"done": 0
	}
	return answer_json

func _step_answer() -> Dictionary:
	if USE_IMG:
		img = self._get_screenshot()
	else:
		img = "0"
	answer_json = {
		"action": "STEP",
		"coord": peg.get_coord(),            # current position and orientation of the peg
		"image": img,
		"done": goal.is_done()
	}
	# print("Success: %s" % goal.is_done())
	return answer_json

func _reset_answer() -> Dictionary:
	answer_json = {
		"action": "RESET",
		"coord": peg.get_coord(),
		"image": self._get_screenshot(),
		"done": 0
	}
	return answer_json

func send_var(msg: String) -> void:
	msg = msg + "<EOF>"
	if client.is_connected_to_host():
		# print("Sending: %s" % msg)
		var error := client.put_data(msg.to_ascii())
		if error != 0:
			print("Error on packet put: %s" % error)

func stop_server() -> void:
	server.stop()


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
