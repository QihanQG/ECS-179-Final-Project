extends BaseBuilding

# Factory handles turret production and upgrades

var production_queue: Array = []
var production_progress: float = 0.0
var base_production_rate: float = 1.0

@export var turret_scene: PackedScene

# References
@onready var spawn_point: Marker3D = $TurretSpawnPoint

# Signals
signal production_completed(turret: Node)
signal production_progress_updated(progress: float)

func _ready():
	building_name = "Factory"
	max_health = 500.0
	super._ready()
	game_manager = get_node("/root/World/GameManager")

func _process(delta):
	if is_operational and !production_queue.is_empty():
		advance_production(delta)

func advance_production(delta: float):
	var production_speed = base_production_rate * (1 + assigned_penguins * 0.2)
	production_progress += delta * production_speed
	
	emit_signal("production_progress_updated", production_progress)
	
	if production_progress >= 100.0:
		complete_production()

func start_turret_production():
	if game_manager.can_afford(get_turret_cost()):
		game_manager.modify_resources(-get_turret_cost())
		production_queue.append("turret")
		production_progress = 0.0

func complete_production():
	if production_queue.size() > 0:
		var item = production_queue.pop_front()
		if item == "turret":
			spawn_turret()
	production_progress = 0.0

func spawn_turret():
	var turret = turret_scene.instantiate()
	spawn_point.add_child(turret)
	emit_signal("production_completed", turret)

func get_turret_cost() -> float:
	return 100.0  
