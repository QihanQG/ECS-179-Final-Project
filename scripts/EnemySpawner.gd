extends MeshInstance3D

@export var show_debug_lines: bool = false
@export var orbit_radius: float = 5.0
@export var angular_speed: float = 1.0
@export var max_enemies: int  = 2


@onready var turret: StaticBody3D = $"../Turret"
@onready var enemy_scene = preload("res://scenes/enemy.tscn")

var enemy_count: int = 1
var spawn_timer: Timer

func _ready() -> void:
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.wait_time = 3.0
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()
	spawn_enemy()  # Spawn first enemy immediately

func _on_spawn_timer_timeout() -> void:
	if enemy_count < max_enemies:
		spawn_enemy()
		enemy_count += 1
	else:
		spawn_timer.stop()

func spawn_enemy() -> void:
	var enemy = enemy_scene.instantiate()
	
	enemy.global_position = global_position
	enemy.orbit_radius = orbit_radius
	enemy.angular_speed = angular_speed
	enemy.show_debug_lines = show_debug_lines
	enemy.health = 500
	
	add_child(enemy)

	enemy.circular_motion_around(turret)
	
	print("Enemy spawned at: ", enemy.global_position)
