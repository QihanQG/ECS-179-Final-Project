extends Node

# Base settings for buildings and units
var total_penguins: int = 0
var assigned_penguins = {
	"factory": 0,
	"research": 0
}

# Base stats that will be modified by penguin assignments
var base_resource_cap: float = 3000.0
var base_production_speed: float = 1.0

# Bonus multipliers per penguin
var resource_cap_per_penguin: float = 1000.0
var production_speed_per_penguin: float = 0.2  # 20% faster per penguin

# Current effective stats
var current_resource_cap: float = base_resource_cap
var current_production_speed: float = base_production_speed

# Signals for system communication
signal penguins_reassigned(location: String, count: int)
signal stats_updated(resource_cap: float, production_speed: float, turret_damage: float)
signal penguin_spawned

func _ready():
	# Start with some initial penguins
	add_penguins(3)

func add_penguins(amount: int) -> void:
	total_penguins += amount
	print("New penguin joined! Total penguins: ", total_penguins)
	emit_signal("penguin_spawned")

func assign_penguins(location: String, count: int) -> bool:
	# Validate the assignment request
	if count < 0 or !assigned_penguins.has(location):
		return false
	
	# Check if we have enough available penguins
	var available = get_available_penguins()
	if count > available:
		print("Not enough available penguins! Available: ", available)
		return false
	
	# Update assignment and recalculate effects
	assigned_penguins[location] = count
	update_building_effects()
	emit_signal("penguins_reassigned", location, count)
	print("Assigned ", count, " penguins to ", location)
	return true

func update_building_effects():
	# Update resource cap from research penguins
	current_resource_cap = base_resource_cap + (assigned_penguins["research"] * resource_cap_per_penguin)
	
	# Update production speed from factory penguins only
	var production_speed = 1.0 + (assigned_penguins["factory"] * production_speed_per_penguin)
	emit_signal("production_speed_changed", production_speed)
	
	print("Effects updated - Resource Cap: ", current_resource_cap, " Production Speed: ", production_speed)

# Utility functions for other systems
func get_assigned_count(location: String) -> int:
	return assigned_penguins.get(location, 0)

func get_available_penguins() -> int:
	var total_assigned = 0
	for count in assigned_penguins.values():
		total_assigned += count
	return total_penguins - total_assigned

func get_resource_cap() -> float:
	return current_resource_cap

func get_production_speed() -> float:
	return current_production_speed
