extends RigidBody

# RL vars
var linear_impulse: Vector3 = Vector3()
var torque_impulse: Vector3 = Vector3()
var current_position: Array
var initial_trans: Vector3
var initial_rot: Vector3

func _ready() -> void:
	initial_trans = self.get_translation()
	initial_rot = self.get_rotation()
	
func _physics_process(delta: float) -> void:
	# Cheat Mode
	# linear_impulse = Vector3(0, 0, -5)
	# torque_impulse = Vector3(0, 0, 0)
	self.apply_torque_impulse  (delta*torque_impulse)
	self.apply_central_impulse(delta*linear_impulse)
	pass


func move(coord) -> void:
	# print("Moving peg by: ", coord)
	var x: float = coord[0]
	var y: float = coord[1]
	var z: float = coord[2]
	var alpha: float = coord[3]
	var beta: float = coord[4]
	var gamma: float = coord[5]
	
	linear_impulse = Vector3(x, y, z)
	torque_impulse = Vector3(alpha, beta, gamma)


func reset() -> void:
	self.set_translation(initial_trans)
	self.set_linear_velocity(Vector3(0, 0, 0))
	self.set_rotation(initial_rot)
	self.set_angular_velocity(Vector3(0, 0, 0))

func get_coord() -> Array:
	var current_trans = self.get_translation()
	var x: float = current_trans[0]
	var y: float = current_trans[1]
	var z: float = current_trans[2]

	var current_rot = self.get_rotation()
	var alpha: float = current_rot[0]
	var beta: float = current_rot[1]
	var gamma: float = current_rot[2]

	return [x, y, z, alpha, beta, gamma]
