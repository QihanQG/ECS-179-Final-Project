extends Node3D

# Wall components references - match your hierarchy
@onready var wall_door = $wall_door
@onready var wall_door2 = $wall_door2
@onready var wonder_walls = $WonderWalls_Second

# Wall properties
var wall_health: float = 1000.0
var max_wall_health: float = 1000.0
var damage_reduction: float = 0.0
var wall_upgrade_level: int = 0

signal wall_damaged(health: float)
signal wall_upgraded(level: int)

func _ready():
	wall_health = max_wall_health
	# Add walls to friendly group for targeting
	if wall_door:
		wall_door.add_to_group("friendly")
	if wall_door2:
		wall_door2.add_to_group("friendly")

func take_damage(damage: float) -> void:
	var reduced_damage = damage * (1.0 - damage_reduction)
	wall_health = max(0, wall_health - reduced_damage)
	emit_signal("wall_damaged", wall_health)
	
	if wall_health <= 0:
		on_wall_destroyed()

func upgrade_wall_defense() -> void:
	wall_upgrade_level += 1
	damage_reduction = min(wall_upgrade_level * 0.1, 0.5)  # Max 50% reduction
	emit_signal("wall_upgraded", wall_upgrade_level)

func on_wall_destroyed() -> void:
	queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("projectiles"):
		if body.has_method("get_damage"):
			take_damage(body.damage)
