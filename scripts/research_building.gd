extends BaseBuilding

# Research building handles three upgrade paths:
# 1. Weapon upgrades
# 2. Wall damage reduction
# 3. Resource capacity increase

enum ResearchFocus {NONE, WEAPONS, WALLS, RESOURCES}

var current_focus: ResearchFocus = ResearchFocus.NONE
var research_progress: float = 0.0
var base_research_rate: float = 1.0

# References to other systems
@onready var wall_system: Node

# Signal for research progress
signal research_completed(type: String)
signal research_progress_updated(focus: String, progress: float)

func _ready():
	building_name = "Research"
	max_health = 500.0
	super._ready()
	setup_references()

func setup_references():
	game_manager = get_node("/root/World/GameManager")
	wall_system = get_node("../WallSystem")

func _process(delta):
	if is_operational and current_focus != ResearchFocus.NONE:
		advance_research(delta)

func advance_research(delta: float):
	var research_speed = base_research_rate * (1 + assigned_penguins * 0.2)
	research_progress += delta * research_speed
	
	emit_signal("research_progress_updated", 
		ResearchFocus.keys()[current_focus].to_lower(), 
		research_progress)
	
	if research_progress >= 100.0:
		complete_research()

func complete_research():
	match current_focus:
		ResearchFocus.WEAPONS:
			# Increase weapon damage
			game_manager.upgrade_weapons()
		ResearchFocus.WALLS:
			# Improve wall defense
			wall_system.upgrade_wall_defense()
		ResearchFocus.RESOURCES:
			# Increase resource cap
			game_manager.upgrade_resource_cap()
	
	emit_signal("research_completed", ResearchFocus.keys()[current_focus].to_lower())
	research_progress = 0.0

func set_research_focus(focus: ResearchFocus):
	if current_focus != focus:
		current_focus = focus
		research_progress = 0.0
