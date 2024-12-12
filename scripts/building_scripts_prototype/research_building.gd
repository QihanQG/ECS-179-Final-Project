extends StaticBody3D

# Existing properties
@export var max_health: float = 100.0
@export var min_health_percentage: float = 20.0
@export var update_interval: float = 5.0

var research_level: int = 0
var current_health: float
var is_functional: bool = true

# Research bonuses
var speed_bonus: float = 5.0
var fire_rate_bonus: float = 0.02
var damage_bonus: float = 2.0

# Add research focus system
enum ResearchFocus {NONE, WEAPONS, WALLS, RESOURCES}
var current_focus: ResearchFocus = ResearchFocus.NONE
var research_progress: float = 0.0

# Cost
var research_costs = {
	ResearchFocus.WEAPONS: 100,
	ResearchFocus.WALLS: 100,
	ResearchFocus.RESOURCES: 100
}

# References
@onready var game_manager = get_node("/root/World/GameManager")

# Signals
signal research_completed(type: String)
signal research_progress_updated(focus: String, progress: float)

func _ready() -> void:
	add_to_group("friendly")
	current_health = max_health
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = update_interval
	timer.timeout.connect(_on_upgrade)
	timer.start()

func _process(delta: float) -> void:
	if is_functional and current_focus != ResearchFocus.NONE:
		advance_research(delta)

func advance_research(delta: float) -> void:
	research_progress += delta * 10.0  # Adjust speed as needed
	emit_signal("research_progress_updated", ResearchFocus.keys()[current_focus].to_lower(), research_progress)
	
	if research_progress >= 100.0:
		complete_research()

func complete_research() -> void:
	if game_manager:
		match current_focus:
			ResearchFocus.WEAPONS:
				game_manager.upgrade_weapons()
			ResearchFocus.WALLS:
				var fortress = get_node("../..")
				if fortress.has_method("upgrade_wall_defense"):
					fortress.upgrade_wall_defense()
			ResearchFocus.RESOURCES:
				game_manager.upgrade_resource_cap()
	
	emit_signal("research_completed", ResearchFocus.keys()[current_focus].to_lower())
	research_progress = 0.0

func set_research_focus(focus: ResearchFocus) -> void:
	if not game_manager.can_afford(research_costs[focus]):
		print("Not enough resources for research!")
		return
		
	if current_focus != focus:
		game_manager.modify_resources(-research_costs[focus])
		current_focus = focus
		research_progress = 0.0
		print("Research focus set to: ", ResearchFocus.keys()[focus])


func _on_upgrade() -> void:
	if current_health > 0 and (current_health / max_health) * 100 > min_health_percentage:
		is_functional = true
		research_level += 1
	else:
		is_functional = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("projectiles"):
		if body.has_method("get_damage"):
			take_damage(body.damage)

func get_turret_upgrades() -> Dictionary:
	if is_functional:
		return {
			"speed": speed_bonus * research_level,
			"fire_rate": fire_rate_bonus * research_level,
			"damage": damage_bonus * research_level
		}
	else:
		return {
			"speed": 0.0,
			"fire_rate": 0.0,
			"damage": 0.0
		}

func take_damage(damage: float) -> void:
	current_health -= damage
	var health_percentage = (current_health / max_health) * 100
	if health_percentage <= min_health_percentage or current_health <= 0:
		is_functional = false
		current_health = 0
		queue_free()
