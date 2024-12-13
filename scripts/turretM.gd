extends Node3D  

var turret: Turret
var factory: Factory

@export var damage: int = 100
@export var current_health: int = 100
@export var target_group: String = "enemies"
@export var debug_mode: bool = false
@export var lock_on_til_death = true
@export var detection_radius: float = 10
@export var pitch_up_max: float = 45
@export var pitch_up_min: float = 10
@export var fire_rate:float = 1
@export var projectile_spee: float = 100
@export var rotation_speed: float = 10.0

@onready var parent_node: Node3D = $"."
@onready var body: Node3D = $body
@onready var head: Node3D = $body/head
@onready var detection_area: Area3D = $DetectionArea
@onready var barrel: Node3D = $body/head/at_barrel/barrel
@onready var projectile_spawn_point: Marker3D = $body/head/at_barrel/barrel/projectile_spawn_point

var projectile_scene = preload("res://scenes/projectiles.tscn")  

var was_factory_spawned: bool = false 


func _ready():
	
	add_to_group("turrets")
	add_to_group("friendly_projectiles")
	var projectile_spawn_points: Array[Marker3D] = [projectile_spawn_point]
	
	
	# Instantiate the Turret class
	turret = Turret.new()
	turret.initialize(parent_node, body, head, detection_area, projectile_spawn_points, projectile_scene,barrel)
	
	
	# properties
	turret.lock_on_till_death = lock_on_til_death
	turret.detection_radius = detection_radius
	turret.enemies = target_group
	turret.barrel_ref = barrel.global_position	
	turret.rotation_speed = rotation_speed
	turret.projectile_speed = projectile_spee
	turret.fire_rate = fire_rate
	turret.debug_mode = debug_mode
	turret.target_mode = Turret.TargetMode.NORMAL 
	turret.max_pitch_up =  -pitch_up_max
	turret.max_pitch_down = pitch_up_min
	turret.damage = damage
	
func _process(delta: float):
	if turret:
		turret.process(delta)
		turret.draw_detection_radius()

func set_factory_spawned() -> void:
	was_factory_spawned = true
	
func take_damage(damage: float) -> void:
	current_health -= damage
	if current_health <= 0:
		queue_free()  

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("projectiles") and not body.is_in_group("friendly_projectiles"):
		if body.has_method("get_damage"):
			take_damage(body.damage)
