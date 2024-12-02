extends Node3D  

var turret: Turret

@onready var turret_parent: StaticBody3D = $"."
@export var debug_mode: bool = false
@export var lock_on_until_death = true


func _ready():
	lock_on_until_death = lock_on_until_death
	# Reference required nodes
	var rotation_area = $TurretRotation  
	var detection_area = $DetectionArea  
	var spawn_point = $TurretRotation/projectile_spawn/projectile_spawn_marker  
	var projectile_scene = preload("res://scenes/projectiles.tscn")  
	var parent_node = turret_parent

	# Instantiate the Turret class
	turret = Turret.new()
	turret.initialize(parent_node, rotation_area, detection_area, spawn_point, projectile_scene)
	
	# properties
	turret.lock_on_till_death = lock_on_until_death
	turret.max_lock_on_angle = 90.0
	turret.rotation_speed = 50.0
	turret.barrel_length = 1.2
	turret.projectile_speed = 120.0
	turret.fire_rate = 0.4
	turret.debug_mode = debug_mode
	turret.target_mode = Turret.TargetMode.PREDICTED_AIM 
	
func _process(delta: float):
	if turret:
		turret.process(delta)
