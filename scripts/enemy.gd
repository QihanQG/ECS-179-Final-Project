extends CharacterBody3D


@export var gravity_force: float = 9.8
@export var movement_speed: float = 4.0
@export var orbit_radius: float = 5.0
@export var angular_speed: float = 1.0
@export var health: float = 100
@export var smoothing_factor: float = 5.0
@export var jump_velocity: float = 4.0

@onready var current_state: String 
@onready var next_state: String
@onready var prev_state: String



var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var theta: float = 0.0
var target_node: Node3D
var current_health: float
var can_jump: bool = true
var show_debug_lines: bool = true


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
		
func jump() -> void:
	if is_on_floor() and can_jump:
		velocity.y = jump_velocity
	

func _on_area_3d_body_entered(body: Node3D) -> void:
		if body.is_in_group("projectiles"):
			take_damage(body.damage)

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
		"jump":
			jump()
			next_state = "idle"
	move_and_slide()



func circular_motion(delta: float) -> void:
	if not target_node:
		return
		
	theta += angular_speed * delta
	
	# Calculate target position on circle
	var center = target_node.global_position

	
	#Current angle relative to center
	var angle_to_center = atan2(global_position.z - center.z, global_position.x - center.x)
	
	#tanget vector. For a radius vector (cos θ, sin θ), its perpendicular is (-sin θ, cos θ)
	#rotating avector 90 degree counterlcockwise: [cos θ, sin θ] → [-sin θ, cos θ]
	var tangent_vector = Vector3(-sin(angle_to_center),0,cos(angle_to_center))
	
	#set velocity in tangential direction
	var target_velocity = tangent_vector  * movement_speed
	
	var current_radius = Vector2(global_position.x - center.x,global_position.z - center.z).length()


	var radius_difference = orbit_radius - current_radius
	var radial_direction = (global_position - center ).normalized()
	target_velocity += radial_direction * radius_difference * 5.0 
	

	velocity = velocity.lerp(target_velocity, smoothing_factor * delta)
	
	
	if show_debug_lines:
		#Draw the circle path
		var segments = 32
		for i in range(segments):
			var angle = (i / float(segments)) * TAU
			var next_angle = ((i + 1) / float(segments)) * TAU
			var start = Vector3(
				center.x + orbit_radius * cos(angle),
				global_position.y,
				center.z + orbit_radius * sin(angle)
			)
			var end = Vector3(
				center.x + orbit_radius * cos(next_angle),
				global_position.y,
				center.z + orbit_radius * sin(next_angle)
			)
			DebugDraw3D.draw_line(start, end, Color.YELLOW)
		
		#Draw radius vector and show current radius
		DebugDraw3D.draw_line(center, global_position, Color.RED)
		
		#Draw tangent vector
		DebugDraw3D.draw_arrow(
			global_position,
			global_position + tangent_vector * 2.0,
			Color.GREEN
		)
		
		#draw radius correction
		if abs(radius_difference) > 0.01:  
			DebugDraw3D.draw_arrow(
				global_position,  
				global_position + radial_direction * abs(radius_difference) * 2.0,  
				Color.BLUE,
				0.5  
			)
		
		#Draw final velocity (made larger and offset)
		DebugDraw3D.draw_arrow(
			global_position + Vector3(0, 1.0, 0),  # up more
			global_position + Vector3(0, 1.0, 0) + target_velocity.normalized() * 3.0,  #
			Color.PURPLE,
			0.3  # Arrow size 
			)
