class_name Factory
extends StaticBody3D

const Turret_1 = preload("res://scenes/Turret Gun.tscn")
const Turret_2 = preload("res://scenes/Turret.tscn")
const Turret_prototype = preload("res://scenes/Turret.tscn")

# Base properties
@export var health: float = 1000.0
@onready var research_building: StaticBody3D = $"../research_building"
@onready var fortress_wall: Node3D = $"../.."

@export var turret_spawn_location: Vector3

var current_health: float
var is_operational: bool = true

signal turret_spawned(turret: Node)

func _ready() -> void:
	add_to_group("friendly")
	current_health = health

func spawn_turret(turret_type: int = 0) -> void:
	if current_health <= 0 or !is_operational:
		return
		
	var turret_scene: PackedScene
	match turret_type:
		0: turret_scene = Turret_prototype
		1: turret_scene = Turret_1
		2: turret_scene = Turret_2
	
	if turret_scene:
		var turret = turret_scene.instantiate()
		fortress_wall.add_child(turret)
		turret.global_position = turret_spawn_location + Vector3(
			randf_range(-10,10),
			-1,
			randf_range(-1,-20)
		)
		
		# Move the upgrade logic here directly
		if research_building and research_building.is_functional:
			var upgrades = research_building.get_turret_upgrades()
			var multiplier = 1.0
			match turret_type:
				0: multiplier = 1.0
				1: multiplier = 1.2
				2: multiplier = 1.5
			
			if turret.has_node("WeaponSystem"):
				var weapon = turret.get_node("WeaponSystem")
				weapon.projectile_speed += upgrades.speed * multiplier
				weapon.fire_rate -= upgrades.fire_rate * multiplier
				weapon.damage += upgrades.damage * multiplier
		
		emit_signal("turret_spawned", turret)

func take_damage(damage: float) -> void:
	current_health = max(0, current_health - damage)
	is_operational = current_health > 0
	
	if current_health <= 0:
		queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("projectiles"):
		if body.has_method("get_damage"):
			take_damage(body.damage)

func get_operational_status() -> bool:
	return is_operational

func get_health() -> float:
	return current_health
