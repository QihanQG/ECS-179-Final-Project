extends StaticBody3D

@export var max_health: float = 100.0
@export var min_health_percentage: float = 20.0
@export var update_interval: float = 5.0


var research_level: int = 0
var current_health: float
var is_functional: bool = true


var speed_bonus: float = 5.0
var fire_rate_bonus: float = 0.02
var damage_bonus: float = 2.0

func _ready() -> void:
	add_to_group("friendly")
	current_health = max_health
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = update_interval
	timer.timeout.connect(_on_upgrade)
	timer.start()

func _on_upgrade() -> void:
	if current_health > 0 and (current_health / max_health) * 100 > min_health_percentage:
		is_functional = true
		research_level += 1
	else:
		is_functional = false
	


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("projectiles"):
		if body.has_method("get_damage"):
			take_damage(body.damage)


func get_turret_upgrades() -> Dictionary:
	
	if is_functional:
		return {
			"speed": speed_bonus * research_level,
			"fire_rate": fire_rate_bonus * research_level,
			"damage": damage_bonus * research_level
		}
	else:
		return {
			"speed": 0.0,
			"fire_rate": 0.0,
			"damage": 0.0
		}


func take_damage(damage: float) -> void:
	current_health -= damage
	var health_percentage = (current_health / max_health) * 100
	if health_percentage <= min_health_percentage or current_health <= 0:
		is_functional = false
		current_health = 0
		queue_free()
