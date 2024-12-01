extends CharacterBody3D

@export var gravity_force: float = 9.8
@export var movement_speed: float = 4.0
@export var orbit_radius: float = 10.0
@export var angular_speed: float = 1.0

@export var health: float = 100.0

@onready var current_state: String 
@onready var next_state: String
@onready var prev_state: String

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var theta: float = 0.0
var target_node: Node3D

var current_health: float


func _ready() -> void:
	add_to_group("enemies")
	current_state = "idle"
	next_state = "idle"
	prev_state = "idle"
	current_health = health


func circular_motion_around(node: Node3D) -> void:
	target_node = node
	next_state = "circle"  

func take_damage(damage: float) -> void:
	current_health -= damage
	
	print("Damage taken!, health: ", current_health)
	
	if current_health <= 0:
		queue_free()

func _physics_process(delta: float) -> void:
	prev_state = current_state
	current_state = next_state
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	match current_state:
		"idle":
			if prev_state != current_state:
				print("Transitioning from idle...")
			velocity = Vector3.ZERO
			
		"walk_forward":
			velocity.x = 0
			velocity.z = -movement_speed
			
		"circle":  
			if target_node:
				circular_motion(delta)
	
	move_and_slide()



func circular_motion(delta: float) -> void:
	if not target_node:
		return
		
	theta += angular_speed * delta
	
	# Calculate target position on circle
	var center = target_node.global_position
	var target_position = Vector3(
		center.x + orbit_radius * cos(theta),
		global_position.y,                     #unchanged in 3d
		center.z + orbit_radius * sin(theta)
	)
	
	var direction = (target_position - global_position).normalized()
	velocity.x = direction.x * movement_speed
	velocity.z = direction.z * movement_speed


func _on_area_3d_body_entered(body: Node3D) -> void:
		if body.is_in_group("projectiles"):
			take_damage(body.damage)
