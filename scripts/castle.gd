extends BaseBuilding

# Castle spawns penguins and houses the king penguin

var penguin_spawn_timer: Timer
var base_spawn_time: float = 30.0  # Spawn every 30 seconds
@export var king_penguin_scene: PackedScene

# References
@onready var king_penguin: Node

signal penguin_spawned
signal king_penguin_damaged

func _ready():
	building_name = "Castle"
	max_health = 1000.0
	super._ready()
	
	setup_king_penguin()
	setup_spawn_timer()
	game_manager = get_node("/root/World/GameManager")

func setup_king_penguin():
	if king_penguin_scene:
		king_penguin = king_penguin_scene.instantiate()
		add_child(king_penguin)
		king_penguin.position = Vector3(0, 0, 0)  # Center of castle

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

# Override damage to affect king penguin
func take_damage(amount: float):
	super.take_damage(amount)
	if king_penguin:
		king_penguin.take_damage(amount)
		emit_signal("king_penguin_damaged", current_health)

# Override destruction to trigger game over
func handle_destruction():
	game_manager.end_game(false)
