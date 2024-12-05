## Initial GameManager: Core coordination system for Penguin Tower Defense
# 
# Current features:
# - Resource management (tested with drain system)
# - Game state tracking
# - Signal system for cross-component communication
#
# Planned integrations:
# - UI system will connect to resource_changed signal
# - Enemy system will use wave management
# - Building system will connect through damage_building()
#
# How:
# 1. Access resource system through modify_resources() and can_afford()
# 2. Connect to signals for state changes
# 3. Use is_game_active() to check game state

extends Node

# Core game state and resource management
var game_state: String = "setup"  # States: setup, playing, paused, ended
var resources: float = 1000.0
var available_penguins: int 

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
var is_draining : bool

# Node references - will be set after buildings are created
#@onready var castle: Node3D
#@onready var factory: Node3D
#@onready var research: Node3D
#@onready var wall_system: Node3D

# Signals for system coordination
signal resource_changed(new_amount: float)
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal building_damaged(building_name: String, current_health: float)
signal game_over(victory: bool)


func _ready():
	is_draining = true
	print("Starting resources: ", resources)
	setup_game()

# the whole process func is just testing resources management for now
func _process(delta: float) -> void:
	if is_draining and game_state == "playing":
		# Drain resources over time
		modify_resources(delta * -10)
		
		# Print when resources drop below certain thresholds
		if resources <= 750 and resources > 740:
			print("Resources dropped below 750!")
		elif resources <= 500 and resources > 490:
			print("Resources dropped below 500!")
		elif resources <= 250 and resources > 240:
			print("Resources dropped below 250!")
		elif resources <= 0:
			print("Resources depleted!")
			is_draining = false  # Stop draining when empty

func setup_game():
	# Initialize node references
	#castle = get_node("../Buildings/Castle")
	#factory = get_node("../Buildings/Factory")
	#research = get_node("../Buildings/Research")
	#wall_system = get_node("../WallSystem")
	
	# Initial game setup
	game_state = "setup"
	resources = 1000.0
	available_penguins = 5
	
	# Emit initial state
	emit_signal("resource_changed", resources)
	
	# Start in playing for testing
	game_state = "playing"


# Function to test turret placement
func try_place_turret(cost: float) -> bool:
	if can_afford(cost):
		modify_resources(-cost)
		return true
	return false


func start_wave():
	if game_state != "playing":
		return
		
	current_wave += 1
	is_wave_active = true
	emit_signal("wave_started", current_wave)


func modify_resources(amount: float):
	resources += amount
	emit_signal("resource_changed", resources)
	print("Resources changed to: ", resources)  # Added for testing

func damage_building(building_name: String, damage: float):
	if building_name in building_health:
		building_health[building_name] -= damage
		emit_signal("building_damaged", building_name, building_health[building_name])
		print("Building ", building_name, " damaged. Health: ", building_health[building_name])
		
		# Game OVER QQ
		if building_name == "castle" and building_health[building_name] <= 0:
			end_game(false)

func end_game(victory: bool):
	game_state = "ended"
	emit_signal("game_over", victory)

# Public API for other systems to use
func get_resources() -> float:
	return resources

func can_afford(cost: float) -> bool:
	return resources >= cost

func is_game_active() -> bool:
	return game_state == "playing"
