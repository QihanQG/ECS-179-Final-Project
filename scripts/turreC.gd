extends Node3D  

var turret: Turret

@export var debug_mode: bool = false
@export var lock_on_til_death = true
@export var detection_radius: float = 10
@export var pitc_up_max: float = 45
@export var pitch_down_min: float = 10


@onready var parent_node: Node3D = $"."
@onready var body: Node3D = $body
@onready var head: Node3D = $body/head
@onready var detection_area: Area3D = $DetectionArea


@onready var projectile_l: Marker3D = $body/head/left_gun/projectile_L

@onready var projectile_r: Marker3D = $body/head/right_gun/projectile_R


@onready var barrel_left: Marker3D = $projectile_spawn_point/barrel_left
@onready var barrel_right: Marker3D = $projectile_spawn_point2/barrel_right

@onready var center_pos: Marker3D = $body/head/center_pos


var projectile_scene = preload("res://scenes/projectiles.tscn")  



func _ready():
	
	var projectile_spawn_points: Array[Marker3D] = [projectile_l,projectile_r]
	
	# Instantiate the Turret class
	turret = Turret.new()
	turret.initialize(parent_node, body, head, detection_area, projectile_spawn_points, projectile_scene, center_pos)

	# properties
	turret.barrel_ref = center_pos.global_position
	turret.detection_radius = detection_radius
	turret.lock_on_till_death = lock_on_til_death
	turret.rotation_speed = 10.0
	turret.projectile_speed = 100.0
	turret.fire_rate = 0.4
	turret.debug_mode = debug_mode
	turret.target_mode = Turret.TargetMode.NORMAL 
	turret.max_pitch_up =  -pitc_up_max
	turret.max_pitch_down = pitch_down_min
	
func _process(delta: float):
	if turret:
		turret.process(delta)
		turret.draw_detection_radius()
