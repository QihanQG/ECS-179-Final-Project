extends Node3D

# Building references - matching your hierarchy
@onready var factory: StaticBody3D = $fortress/factory
@onready var research_building: StaticBody3D = $fortress/research_building
@onready var turret_spawner: StaticBody3D = $"../Turret_spawner"
@onready var turret_mounts = $fortress/AreaD3


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
	print("Town initialized at: ", global_position)
	#if factory and turret_spawner:
		#factory.turret_spawn_location = turret_spawner.global_position
	setup_turret_mounts()

func setup_turret_mounts() -> void:
	if not turret_mounts:
		push_error("AreaD3 node not found")
		return
		
	var mount_count = 8
	for i in range(mount_count):
		var angle = (i / float(mount_count)) * TAU
		var pos = Vector3(
			cos(angle) * (town_radius - 0.5),
			2.0,  # Mount height
			sin(angle) * (town_radius - 0.5)
		)
		create_turret_mount(pos)

func create_turret_mount(position: Vector3) -> void:
	if not turret_mounts:
		return
		
	var mount = Marker3D.new()
	turret_mounts.add_child(mount)
	mount.global_position = position
	mount.look_at(global_position, Vector3.UP)

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
	if event.is_action_pressed("upgrade_weapons"): # R
		research_building.set_research_focus(research_building.ResearchFocus.WEAPONS) 
	elif event.is_action_pressed("upgrade_walls"): # T
		research_building.set_research_focus(research_building.ResearchFocus.WALLS) 

func can_afford(cost: int) -> bool:
	return resources >= cost

func spend_resources(amount: int) -> void:
	resources = max(0, resources - amount)

func add_resources(amount: int) -> void:
	resources += amount

func _process(_delta: float) -> void:
	if research_building and not research_building.is_functional:
		print("Research building is destroyed")
