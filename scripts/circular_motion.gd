class_name circular_motion

var _target_node: Node3D
var _radius: float
var _angular_speed: float
var _theta: float = 0.0

func _init(target: Node3D, radius: float = 10.0, speed: float = 1.0) -> void:
	_target_node = target
	_radius = radius
	_angular_speed = speed

func update(delta: float) -> Vector3:
	_theta += _angular_speed * delta
	
	if not _target_node:
		return Vector3.ZERO
		
	var center = _target_node.global_position
	
	return Vector3(
		center.x + _radius * cos(_theta),
		center.y,
		center.z + _radius * sin(_theta)
	)
