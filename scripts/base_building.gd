extends StaticBody3D

class_name BaseBuilding

# Core building properties
@export var building_name: String = "base"
@export var max_health: float = 100.0
var current_health: float
var is_operational: bool = true

# Penguin workforce management
var assigned_penguins: int = 0
var max_penguins: int = 5

# Reference to game manager
var game_manager: Node

# Signals for building state changes
signal health_changed(current: float, maximum: float)
signal building_destroyed
signal penguin_count_changed(new_count: int)
signal operational_status_changed(is_operational: bool)

func _ready():
	initialize_building()
	setup_game_manager()
	add_to_group("buildings")

func initialize_building():
	current_health = max_health
	print("Building initialized: ", building_name)
	emit_signal("health_changed", current_health, max_health)

func setup_game_manager():
	game_manager = get_node("/root/World/GameManager")
	if !game_manager:
		push_error("GameManager not found for building: " + building_name)
		return
	
	# Connect to game manager signals as needed
	# Implement in child classes based on specific needs

func take_damage(amount: float) -> void:
	if !is_operational:
		return
		
	current_health = max(0, current_health - amount)
	emit_signal("health_changed", current_health, max_health)
	
	if current_health <= 0:
		on_destroyed()

func on_destroyed() -> void:
	is_operational = false
	emit_signal("building_destroyed")
	emit_signal("operational_status_changed", false)
	handle_destruction()

func handle_destruction() -> void:
	# Override in child classes for specific destruction behavior
	pass

func assign_penguins(count: int) -> bool:
	if count < 0 or count > max_penguins:
		return false
	
	assigned_penguins = count
	emit_signal("penguin_count_changed", assigned_penguins)
	on_penguin_assignment_changed()
	return true

func on_penguin_assignment_changed() -> void:
	# Override in child classes to implement specific penguin effects
	pass

# Virtual methods for child classes
func get_building_type() -> String:
	return building_name

func get_efficiency() -> float:
	# Base efficiency calculation
	return 1.0 + (assigned_penguins * 0.2)

func _process(_delta: float) -> void:
	# Override in child classes for building-specific processing
	pass

func can_interact() -> bool:
	return is_operational

# Public API for interaction
func get_health_percentage() -> float:
	return (current_health / max_health) * 100.0

func get_assigned_penguins() -> int:
	return assigned_penguins
