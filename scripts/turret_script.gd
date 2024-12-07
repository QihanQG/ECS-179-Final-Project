extends Node3D  

var turret: Turret

@export var debug_mode: bool = false
@export var lock_on_til_death = true
@export var detection_radius: float = 10
@export var elevation_max: float = 60
@export var elevation_min: float = 30


@onready var parent_node: Node3D = $"."

@onready var body: Node3D = $body
@onready var head: Node3D = $body/head
@onready var detection_area: Area3D = $DetectionArea
@onready var projectile_spawn_marker: Marker3D = $body/head/projectile_spawn_marker

var projectile_scene = preload("res://scenes/projectiles.tscn")  


func _ready():

	# Instantiate the Turret class
	turret = Turret.new()
	turret.initialize(parent_node, body, head, detection_area, projectile_spawn_marker, projectile_scene)

	# properties
	turret.detection_radius = detection_radius
	turret.lock_on_till_death = lock_on_til_death
	turret.rotation_speed = 10.0
	turret.projectile_speed = 100.0
	turret.fire_rate = 0.4
	turret.debug_mode = debug_mode
	turret.target_mode = Turret.TargetMode.NORMAL 
	turret.max_pitch_up =  -elevation_max
	turret.max_pitch_down = elevation_min
	
func _process(delta: float):
	if turret:
		turret.process(delta)
		turret.draw_detection_radius()
