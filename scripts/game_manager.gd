extends Node

# Core game state and resource management
var game_state: String = "setup"  # States: setup, playing, paused, ended
var resources: float = 1000.0

# Penguin management system
var total_penguins: int = 5
var assigned_penguins = {
	"factory": 0,
	"research": 0
}

# Building effects from penguin assignments
var base_resource_cap: float = 5000.0
var current_resource_cap: float = base_resource_cap
var resource_cap_per_penguin: float = 1000.0
var production_speed_per_penguin: float = 0.2

# Wave management
var current_wave: int = 0
var is_wave_active: bool = false
var enemies_remaining: int = 0

# Building states tracking
var building_health = {
	"castle": 1000.0,
	"factory": 500.0,
	"research": 500.0
}

# Debug
var is_draining: bool = false

# Signals for system coordination
signal resource_changed(new_amount: float)
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal building_damaged(building_name: String, current_health: float)
signal game_over(victory: bool)
signal penguins_assigned(location: String, count: int)
signal production_speed_changed(new_speed: float)

func _ready():
	is_draining = true
	print("Starting resources: ", resources)
	setup_game()

func _process(delta: float) -> void:
	if is_draining and game_state == "playing":
		#modify_resources(delta * -10)
		
		# Print when resources drop below certain thresholds
		if resources <= 750 and resources > 740:
			print("Resources dropped below 750!")
		elif resources <= 500 and resources > 490:
			print("Resources dropped below 500!")
		elif resources <= 250 and resources > 240:
			print("Resources dropped below 250!")
		elif resources <= 0:
			print("Resources depleted!")
			is_draining = false

func setup_game():
	game_state = "setup"
	resources = 1000.0
	update_building_effects()
	emit_signal("resource_changed", resources)
	game_state = "playing"

# Penguin management functions
func assign_penguins(location: String, count: int) -> bool:
	if count < 0 or !assigned_penguins.has(location):
		return false
	
	var available = get_available_penguins()
	if count > available:
		print("Not enough available penguins! Available: ", available)
		return false
	
	assigned_penguins[location] = count
	update_building_effects()
	emit_signal("penguins_assigned", location, count)
	print("Assigned ", count, " penguins to ", location)
	return true

func update_building_effects():
	current_resource_cap = base_resource_cap + (assigned_penguins["research"] * resource_cap_per_penguin)
	var production_speed = 1.0 + (assigned_penguins["factory"] * production_speed_per_penguin)
	emit_signal("production_speed_changed", production_speed)
	print("Effects updated - Resource Cap: ", current_resource_cap, " Production Speed: ", production_speed)

func get_available_penguins() -> int:
	var total_assigned = 0
	for count in assigned_penguins.values():
		total_assigned += count
	return total_penguins - total_assigned

# Resource management
func try_place_turret(cost: float) -> bool:
	if can_afford(cost):
		modify_resources(-cost)
		return true
	return false

func modify_resources(amount: float):
	resources = min(current_resource_cap, resources + amount)
	emit_signal("resource_changed", resources)
	print("Resources changed to: ", resources, " (Cap: ", current_resource_cap, ")")

# Wave management
func start_wave():
	if game_state != "playing":
		return
		
	current_wave += 1
	is_wave_active = true
	emit_signal("wave_started", current_wave)

# Building management
func damage_building(building_name: String, damage: float):
	if building_name in building_health:
		building_health[building_name] -= damage
		emit_signal("building_damaged", building_name, building_health[building_name])
		print("Building ", building_name, " damaged. Health: ", building_health[building_name])
		
		if building_name == "castle" and building_health[building_name] <= 0:
			end_game(false)

func end_game(victory: bool):
	game_state = "ended"
	emit_signal("game_over", victory)

# Public API
func get_resources() -> float:
	return resources

func can_afford(cost: float) -> bool:
	return resources >= cost

func is_game_active() -> bool:
	return game_state == "playing"

func get_production_speed() -> float:
	return 1.0 + (assigned_penguins["factory"] * production_speed_per_penguin)
