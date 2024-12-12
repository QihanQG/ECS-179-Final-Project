class_name Factory
extends StaticBody3D

const Turret_1 = preload("res://scenes/Turret Gun.tscn")
const Turret_2 = preload("res://scenes/Turret Gun 2.tscn")
const Turret_protype = preload("res://scenes/Turret.tscn")

@onready var turret_spawn_1: Marker3D = $"../../turret_spawn_1"
@onready var turret_spawn_2: Marker3D = $"../../turet_spawn_2"
@onready var turret_spawn_3: Marker3D = $"../../turret_spawn_3"
@onready var turret_spawn_4: Marker3D = $"../../turret_spawn_4"


@export var health: float = 1000.0
@export var spawn_offset: Vector3 = Vector3(1, -1, -4)

@onready var research_building: StaticBody3D = $"../research_building"
@onready var fortress_wall: Node3D = $"../.."

var current_health: float
var is_operational: bool = true

var spawn_points: Array[Marker3D]
var occupied_spawn_points: Array[Marker3D] = []
signal turret_spawned(turret: Node)


func _ready() -> void:
	add_to_group("friendly")
	current_health = health
	spawn_points = [turret_spawn_1, turret_spawn_2, turret_spawn_3, turret_spawn_4]

	
func spawn_point_available() -> Marker3D:
	occupied_spawn_points = occupied_spawn_points.filter(func(point): return point != null)
	var available_points: Array[Marker3D] = []
	for point in spawn_points:
		if not occupied_spawn_points.has(point):
			available_points.append(point)
	print("Available points: ", available_points.size())

	if available_points.is_empty():
		print("No available spawn points!")
		return null
	available_points.shuffle()
	return available_points[0]
	
	
func spawn_turret(turret_type: int = 0) -> void:
	if current_health <= 0 or !is_operational:
		return

	var spawn_point = spawn_point_available()
	if not spawn_point:
		return
	
	var turret_scene: PackedScene
	match turret_type:
		0: turret_scene = Turret_protype
		1: turret_scene = Turret_1
		2: turret_scene = Turret_2
	
	if turret_scene:
		var turret = turret_scene.instantiate()
		fortress_wall.add_child(turret)
		turret.scale = Vector3(0.5,0.5,0.5) #make he turret 50% smaller
		turret.global_position = spawn_point.global_position
		turret.add_to_group("turret")
		turret.set_factory_spawned()
		
		#spawn point taken
		occupied_spawn_points.append(spawn_point)
		
		apply_research_upgrades(turret, turret_type)
		emit_signal("turret_spawned", turret)

func apply_research_upgrades(turret: Node, turret_type: int) -> void:
	if research_building and research_building.is_functional:
		var upgrades = research_building.get_turret_upgrades()
		
		var multiplier = 1.0
		match turret_type:
			0: multiplier = 1.0
			1: multiplier = 1.2
			2: multiplier = 1.5
		
		turret.turret.projectile_speed += upgrades.speed * multiplier
		turret.turret.fire_rate = turret.turret.fire_rate - upgrades.fire_rate * multiplier
		turret.turret.damage += upgrades.damage * multiplier

func take_damage(damage: float) -> void:
	current_health -= current_health - damage
	is_operational = current_health > 0
	
	if current_health <= 0:
		queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("projectiles"):
		if body.has_method("get_damage"):
			take_damage(body.damage)
			print("Factory health: ", current_health)

#free up the spawn_points when a turret destroyed
func turret_destroyed(turret: Node) -> void:
	for spawn_point in occupied_spawn_points:
		if spawn_point.global_position.distance_to(turret.global_position) < 0.1:
			occupied_spawn_points.erase(spawn_point)
			print("Spawn point freed")
			break
