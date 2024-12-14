extends Node

# Core game properties
var game_state: String = "setup"
var resources: float = 1000.0
var total_penguins: int = 5

# Resource management
var base_resource_cap: float = 5000.0
var current_resource_cap: float = base_resource_cap
var resource_cap_per_penguin: float = 1000.0
var production_speed_per_penguin: float = 0.2

var weapon_damage_multiplier: float = 1.0
var weapon_damage_increase: float = 0.2
var max_resource_cap_base: float = 10000.0

# Game state
var current_wave: int = 0
var is_wave_active: bool = false
var enemies_remaining: int = 0

# Penguin management
var assigned_penguins = {
	"factory": 0,
	"research": 0
}

# Signals
signal resource_changed(new_amount: float)
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal building_damaged(building_name: String, current_health: float)
signal game_over(victory: bool)
signal penguins_assigned(location: String, count: int)
signal production_speed_changed(new_speed: float)

func _ready():
	print("Starting resources: ", resources)
	setup_game()

func setup_game():
	game_state = "setup"
	resources = 1000.0
	update_building_effects()
	emit_signal("resource_changed", resources)
	game_state = "playing"

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

func get_available_penguins() -> int:
	var total_assigned = 0
	for count in assigned_penguins.values():
		total_assigned += count
	return total_penguins - total_assigned

func upgrade_weapons() -> void:
	weapon_damage_multiplier += weapon_damage_increase
	print("Weapons upgraded! New multiplier: ", weapon_damage_multiplier)

func upgrade_resource_cap() -> void:
	base_resource_cap = min(base_resource_cap * 1.5, max_resource_cap_base)
	update_building_effects()

func get_weapon_damage_multiplier() -> float:
	return weapon_damage_multiplier

func modify_resources(amount: float):
	resources = min(current_resource_cap, resources + amount)
	print("after modified", resources)
	emit_signal("resource_changed", resources)

func start_wave():
	if game_state != "playing":
		return
	
	current_wave += 1
	is_wave_active = true
	emit_signal("wave_started", current_wave)

func damage_building(building_name: String, damage: float):
	emit_signal("building_damaged", building_name, damage)
	
	if building_name == "castle" or building_name == "fortress" and damage <= 0:
		end_game(false)

func end_game(victory: bool):
	game_state = "ended"
	emit_signal("game_over", victory)

func can_afford(cost: float) -> bool:
	return resources >= cost

func is_game_active() -> bool:
	return game_state == "playing"

func get_production_speed() -> float:
	return 1.0 + (assigned_penguins["factory"] * production_speed_per_penguin)
