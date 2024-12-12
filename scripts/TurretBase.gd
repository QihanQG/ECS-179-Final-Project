# base_turret.gd
class_name BaseTurret
extends Node3D

# Common configurable properties
@export_group("Turret Stats")
@export var damage: int = 10
@export var current_health: int = 100
@export var target_group: String = "enemies"
@export var detection_radius: float = 10.0
@export var fire_rate: float = 1.0
@export var projectile_speed: float = 100.0
@export var rotation_speed: float = 10.0

@export_group("Turret Settings")
@export var debug_mode: bool = false
@export var lock_on_till_death: bool = true
@export var pitch_up_max: float = 45.0
@export var pitch_down_max: float = 10.0

# Common node references
@onready var parent_node: Node3D = $"."
@onready var body: Node3D = $body
@onready var head: Node3D = $body/head
@onready var detection_area: Area3D = $DetectionArea

# Common variables
var turret: Turret
var factory: Factory
var was_factory_spawned: bool = false
var projectile_scene = preload("res://scenes/projectiles.tscn")

func _ready() -> void:
	add_to_group("turrets")
	add_to_group("friendly_projectiles")
	setup_turret()

# Virtual method to be overridden by child classes
func setup_turret() -> void:
	var spawn_points = get_spawn_points()
	var barrel_ref = get_barrel_reference()
	
	turret = Turret.new()
	turret.initialize(
		parent_node,
		body,
		head,
		detection_area,
		spawn_points,
		projectile_scene,
		barrel_ref
	)
	
	configure_turret()

# Virtual method to get spawn points - override in child classes
func get_spawn_points() -> Array[Marker3D]:
	return []

# Virtual method to get barrel reference - override in child classes
func get_barrel_reference() -> Node3D:
	return null

# Configure common turret properties
func configure_turret() -> void:
	turret.enemies = target_group
	turret.detection_radius = detection_radius
	turret.lock_on_till_death = lock_on_till_death
	turret.rotation_speed = rotation_speed
	turret.projectile_speed = projectile_speed
	turret.fire_rate = fire_rate
	turret.debug_mode = debug_mode
	turret.target_mode = Turret.TargetMode.NORMAL
	turret.max_pitch_up = -pitch_up_max
	turret.max_pitch_down = pitch_down_max
	turret.damage = damage

func _process(delta: float) -> void:
	if turret:
		turret.process(delta)
		turret.draw_detection_radius()

func set_factory_spawned() -> void:
	was_factory_spawned = true

func take_damage(damage: float) -> void:
	current_health -= damage
	if current_health <= 0:
		if factory and was_factory_spawned:
			factory.turret_destroyed(self)
		queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("projectiles") and not body.is_in_group("friendly_projectiles"):
		if body.has_method("get_damage"):
			take_damage(body.damage)
