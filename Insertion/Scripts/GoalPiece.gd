extends Spatial

export(NodePath) var pathToPeg

var done: bool = false
var position: PoolVector3Array
var peg: Node

func _ready() -> void:
	peg = get_node(pathToPeg)


func _on_GoalPiece_body_shape_entered(body_id, _body, _body_shape, _area_shape) -> void:
	if body_id == peg.get_instance_id():
		done = true


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
	
#	position = PoolVector3Array()
#	position.append(self.get_translation())
#	position.append(self.get_rotation())
#
#	return Array(position)


func is_done() -> bool:
	return done

func set_done(state: bool) -> void:
	done = state






