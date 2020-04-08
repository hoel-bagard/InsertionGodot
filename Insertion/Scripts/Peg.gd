extends KinematicBody

# Manual mode vars
var speed = 500
var direction: Vector3 = Vector3()
const gravity: float = -9.81

# RL vars
var linear_velocity: Vector3 = Vector3()
var angular_velocity: Vector3 = Vector3()
var current_position: Array
var initial_trans: Vector3
var initial_rot: Vector3

func _ready() -> void:
	initial_trans = self.get_translation()
	initial_rot = self.get_rotation()
	
func _physics_process(delta: float) -> void:
#	manual_move(delta)
#	linear_velocity = move_and_slide(linear_velocity * delta, Vector3(0, 1, 0))
	rotate_x(angular_velocity[0] * delta)
	rotate_y(angular_velocity[1] * delta)
	rotate_z(angular_velocity[2] * delta)
	pass


func move(coord) -> void:
	# print("Moving peg by: ", coord)
	var x: float = coord[0]
	var  y: float = coord[1]
	var  z: float = coord[2]
	var alpha: float = coord[3]
	var beta: float = coord[4]
	var gamma: float = coord[5]
	
	linear_velocity = Vector3(x, y, z)
	angular_velocity = Vector3(alpha, beta, gamma)
#
	self.set_translation(self.get_translation() + linear_velocity)
	# self.set_rotation(self.get_rotation() + angular_velocity)

func reset() -> void:
	self.set_translation(initial_trans)
	self.set_rotation(initial_rot)

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
	
#	current_position = PoolVector3Array()
#	current_position.append(self.get_translation())
#	current_position.append(self.get_rotation())
#	return current_position
#
#	var current_trans = PoolVector3Array()
#	current_trans.append(self.get_translation())
#	current_trans = Array(current_trans)
#	var current_rot = PoolVector3Array()
#	current_trans.append(self.get_rotation())
#	current_rot = Array(current_rot)
#	current_position = current_trans + current_rot
#	return current_position


func manual_move(delta) -> void:
	direction = Vector3(0, 0, 0)
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_up"):
		direction.z -= 1
	if Input.is_action_pressed("ui_down"):
		direction.z += 1

	direction = direction.normalized()
	direction = direction * speed *delta

	linear_velocity.x = direction.x
	linear_velocity.z = direction.z
	linear_velocity.y += gravity * delta

	linear_velocity = move_and_slide(linear_velocity, Vector3(0, 1, 0))

	if is_on_floor() and Input.is_key_pressed(KEY_SPACE):
		linear_velocity.y = 10
