extends Node3D

@onready var production_building: StaticBody3D = $fortress/production_building
@onready var research_building: StaticBody3D = $fortress/research_building

var resources: int = 1000

@export var turret_prototype_cost: int = 100
@export var turret_2_cost: int = 200
@export var turret_1_cost: int = 300
@onready var turret_spawner: StaticBody3D = $"../Turret_spawner"

func _ready() -> void:
	production_building.turret_spawn_location = turret_spawner.global_position
	
	

func _input(event: InputEvent) -> void:
	if not production_building:
		return
		
	if event.is_action_pressed("spawn_turret_prototype"):
		production_building.spawn_turret(0)
		spend_resources(turret_prototype_cost)
		
	#elif event.is_action_pressed("spawn_turret_1") and can_afford(turret_1_cost):
		#production_building.spawn_turret(1)
		#spend_resources(turret_1_cost)
		#
	#elif event.is_action_pressed("spawn_turret_2") and can_afford(turret_2_cost):
		#production_building.spawn_turret(2)
		#spend_resources(turret_2_cost)


func can_afford(cost: int) -> bool:
	return resources >= cost

func spend_resources(amount: int) -> void:
	resources = max(0, resources - amount)

func add_resources(amount: int) -> void:
	resources += amount

func _process(_delta: float) -> void:
	if research_building and not research_building.is_functional:
		print("Research building is destroyed")
