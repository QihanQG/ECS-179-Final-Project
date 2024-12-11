extends Node3D

@onready var camera_pivot: Node3D = $CameraPivot

var rotation_speed = 8

func _process(delta):
	camera_pivot.rotation_degrees.y += delta * rotation_speed
