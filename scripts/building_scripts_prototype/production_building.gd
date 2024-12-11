extends StaticBody3D

const Turret_1 = preload("res://scenes/Turret Gun.tscn")
const Turret_2 = preload("res://scenes/Turret.tscn")
const Turret_protype = preload("res://scenes/Turret.tscn")

@export var health: float = 1000.0
@export var spawn_offset: Vector3 = Vector3(1, -1, -4)

@onready var research_building: StaticBody3D = $"../research_building"
@onready var fortress_wall: Node3D = $"../.."

@export var turret_spawn_location: Vector3


var current_health: float

func _ready() -> void:
	add_to_group("friendly")
	health = health
	

func spawn_turret(turret_type: int = 0) -> void:
	if health <= 0:
		return
		
	var turret_scene: PackedScene
	match turret_type:
		0: turret_scene = Turret_protype
		1: turret_scene = Turret_1
		2: turret_scene = Turret_2
	
	if turret_scene:
		var turret = turret_scene.instantiate()
		fortress_wall.add_child(turret)
		turret.global_position = turret_spawn_location  + Vector3(randf_range(-10,10),-1,randf_range(-1,-20))
		
		# only ungrade the new turret when it research building is not destroyed
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
	health -=  damage
	
	if health == 0:
		queue_free()
	

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("projectiles"):
		if body.has_method("get_damage"):
			take_damage(body.damage)
			print("current health: ", health)
