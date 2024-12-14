extends Node3D

# Castle properties
var building_name: String = "Castle"
var max_health: float = 1000.0
var current_health: float
var is_operational: bool = true

# Spawning system
var penguin_spawn_timer: Timer
var base_spawn_time: float = 30.0  # Spawn every 30 seconds
@export var king_penguin_scene: PackedScene

# References
@onready var king_penguin: Node
var game_manager: Node

# Signals
signal penguin_spawned
signal king_penguin_damaged

func _ready():
	current_health = max_health
	add_to_group("friendly")
	setup_king_penguin()
	setup_spawn_timer()
	game_manager = get_node("/root/World/GameManager")

func setup_king_penguin():
	if king_penguin_scene:
		king_penguin = king_penguin_scene.instantiate()
		add_child(king_penguin)
		king_penguin.position = Vector3(0, 0, 0)  # Center of castle
		#king_penguin.scale = Vector3(0.5,0.5,0.5)

func setup_spawn_timer():
	penguin_spawn_timer = Timer.new()
	add_child(penguin_spawn_timer)
	penguin_spawn_timer.wait_time = base_spawn_time
	penguin_spawn_timer.connect("timeout", spawn_penguin)
	penguin_spawn_timer.start()

func spawn_penguin():
	if is_operational:
		game_manager.total_penguins += 1
		emit_signal("penguin_spawned")

func take_damage(amount: float):
	current_health = max(0, current_health - amount)
	
	if king_penguin:
		king_penguin.take_damage(amount)
		emit_signal("king_penguin_damaged", current_health)
	
	if current_health <= 0:
		is_operational = false
		handle_destruction()

func handle_destruction():
	if game_manager:
		game_manager.end_game(false)

func _on_area_3d_body_entered(body: Node3D):
	if body.is_in_group("projectiles"):
		if body.has_method("get_damage"):
			take_damage(body.damage)
