extends RigidBody3D  

@export var lifetime: float = 7.0  #time before the projectile is destroyed 
@export var damage: float = 10.0
var timer: Timer  

func _ready():
	add_to_group("projectiles")
	add_to_group("friendly_projectiles")
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = lifetime
	timer.timeout.connect(queue_free)  
	timer.start()
	
func _on_body_entered(body): 
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()  

func get_damage() -> float:
	return damage

func set_damage(new_damage: float) -> void:
	damage = new_damage
