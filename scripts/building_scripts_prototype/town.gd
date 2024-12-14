extends Node3D

# Building references - matching your hierarchy
@onready var factory: StaticBody3D = $fortress/factory
@onready var research_building: StaticBody3D = $fortress/research_building
@onready var turret_spawner: StaticBody3D = $"../Turret_spawner"
@onready var turret_mounts = $fortress/Area3D


# Resource management
var resources: int = 1000

# Turret costs
@export var turret_prototype_cost: int = 100
@export var turret_2_cost: int = 200
@export var turret_1_cost: int = 300

# Town & Wall properties
var town_radius: float = 15.0
var show_debug_lines: bool = true
var wall_upgrade_level: int = 0
var damage_reduction: float = 0.0

signal wall_upgraded(level: int)

func _ready() -> void:
	#global_position = Vector3(33, 3.5, -5)
	print("Town initialized at: ", global_position)
	#if factory and turret_spawner:
		#factory.turret_spawn_location = turret_spawner.global_position


func upgrade_wall_defense() -> void:
	wall_upgrade_level += 1
	damage_reduction = min(wall_upgrade_level * 0.1, 0.5)  # Max 50% damage reduction
	emit_signal("wall_upgraded", wall_upgrade_level)

func _input(event: InputEvent) -> void:
	if not factory:
		return
		
	if event.is_action_pressed("spawn_turret_prototype") and can_afford(turret_prototype_cost):
		factory.spawn_turret(0)
		spend_resources(turret_prototype_cost)
		
	#elif event.is_action_pressed("spawn_turret_1") and can_afford(turret_1_cost):
		#factory.spawn_turret(1)
		#spend_resources(turret_1_cost)
		
	#elif event.is_action_pressed("spawn_turret_2") and can_afford(turret_2_cost):
		#factory.spawn_turret(2)
		#spend_resources(turret_2_cost)
		
	# Research upgrades testing
	#if event.is_action_pressed("upgrade_weapons"): # R
		#research_building.set_research_focus(research_building.ResearchFocus.WEAPONS) 
	#elif event.is_action_pressed("upgrade_walls"): # T
		#research_building.set_research_focus(research_building.ResearchFocus.WALLS) 
	#elif event.is_action_pressed("upgrade_resources"): # Y
		#research_building.set_research_focus(research_building.ResearchFocus.RESOURCES) 

func can_afford(cost: int) -> bool:
	return resources >= cost

func spend_resources(amount: int) -> void:
	resources = max(0, resources - amount)

func add_resources(amount: int) -> void:
	resources += amount

func _process(_delta: float) -> void:
	pass
