extends Node3D

@onready var wall_door = $"wall_door"
@onready var wall_door2 = $"wall_door/wall_door2"
@onready var wonder_walls = $"WonderWalls_SecondAge"
@onready var main_area = $"Area3D"

# Wall properties
var building_name: String = "Fortress"
var wall_health: float = 1000.0
var max_wall_health: float = 1000.0
var damage_reduction: float = 0.0
var wall_upgrade_level: int = 0

signal wall_damaged(health: float)
signal wall_upgraded(level: int)
signal game_over(victory: bool)

@onready var game_manager = get_node("root/World/GameManager")

func _ready():
	wall_health = max_wall_health
	# Add walls to friendly group for targeting
	if wall_door:
		wall_door.add_to_group("friendly")
	if wall_door2:
		wall_door2.add_to_group("friendly")
	if main_area:
		main_area.add_to_group("friendly")
		print("Area 3D found!") #debug

func add_to_friendly_group():
	if wall_door:
		wall_door.add_to_group("friendly")
		print("Wall added to friendly group")

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
	emit_signal("game_over", false)
	#Get reference to GameManager and call end_game
	if game_manager:
		game_manager.end_game(false)

func setup_collision_detection():
	if main_area:
		main_area.connect("body_entered", _on_area_3d_body_entered)
		print("Collision detection setup complete")

func _on_area_3d_body_entered(body: Node3D) -> void:
	print("Body entered: ", body.name)  # Debug line
	print("Body groups: ", body.get_groups())
	
	if body.is_in_group("enemies"):
		# Game over when zombie touches the fortress
		print("enemies touch fortress!")
		emit_signal("game_over", false)
		if game_manager:
			game_manager.end_game(false)
			
	elif body.is_in_group("projectiles"):
		print("getting attack!")
		if body.has_method("get_damage"):
			take_damage(body.damage)
			
func get_damage_reduction() -> float:
	return damage_reduction

func get_wall_health() -> float:
	return wall_health

func get_max_wall_health() -> float:
	return max_wall_health
