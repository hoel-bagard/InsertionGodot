extends KinematicBody

var speed = 500
var direction = Vector3()
var gravity = -9.81
var linear_velocity = Vector3()
var angular_velocity = Vector3()


func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	# manual_move(delta)
	linear_velocity = move_and_slide(linear_velocity, Vector3(0, 1, 0))
	rotate_x(angular_velocity[0] * delta)
	rotate_y(angular_velocity[1] * delta)
	rotate_z(angular_velocity[2] * delta)


func move(coord):
	print("Moving peg by: ", coord)
	var x: float = coord[0]
	var  y: float = coord[1]
	var  z: float = coord[2]
	var alpha: float = coord[3]
	var beta: float = coord[4]
	var gamma: float = coord[5]
	linear_velocity = Vector3(x, y, z)
	angular_velocity = Vector3(alpha, beta, gamma)

	var pos = self.get_translation()
	x = pos[0]
	y = pos[1]
	z = pos[2]
	var rot = self.get_rotation()
	alpha = rot[0]
	beta = rot[1]
	gamma = rot[2]
	return [x, y, z, alpha, beta, gamma]


func manual_move(delta):
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


func jump():
	if is_on_floor():
		linear_velocity.y = 10
