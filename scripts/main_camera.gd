extends Camera3D

@export var movement_speed: float = 12
@export var mouse_sensitivity: float = 0.002
@export var zoom_speed: float = 1.0
@export var max_zoom: float = 10.0
@export var is_friendly: bool 

@export var x_min: float = -22.0 # Left
@export var x_max: float = 18.0  # Right
@export var y_min: float = 10.0  # Minimum camera height
@export var y_max: float = 45.0  # Maximum camera height
@export var z_min: float = -20.0 # Bottom
@export var z_max: float = 16.0  # Top

var current_zoom_level: float = 0.0

@onready var cam_body: CharacterBody3D = $cam_body

func _ready() -> void:
	if is_friendly:
		cam_body.add_to_group("friendly")
	set_current(true)

# Handle input events (mouse clicks and WASD movement)
func _input(event: InputEvent) -> void:
	handle_mouse_wheel(event)

# Handle mouse wheel for zooming
func handle_mouse_wheel(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_wheel_up"):
		zoom_camera(1)
	elif event.is_action_pressed("mouse_wheel_down"):
		zoom_camera(-1)

func zoom_camera(direction: int) -> void:
	var forward_vector = -global_transform.basis.z
	var zoom_amount = direction * zoom_speed
	
	var new_zoom = current_zoom_level + zoom_amount
	if absf(new_zoom) <= max_zoom:
		current_zoom_level = new_zoom
		global_position += forward_vector * zoom_amount
		enforce_bounds()  # Ensure the zoom doesn't take the camera out of bounds

# Handle keyboard input for camera movement
func _process(delta: float) -> void:
	handle_keyboard_movement(delta)
	enforce_bounds()  # Apply bounds after movement

# Move camera based on keyboard input
func handle_keyboard_movement(delta: float) -> void:
	var input_dir = Vector3.ZERO
	
	# Get input direction
	if Input.is_action_pressed("forward"):
		input_dir.z -= 1
	if Input.is_action_pressed("backward"):
		input_dir.z += 1
	if Input.is_action_pressed("left"):
		input_dir.x -= 1
	if Input.is_action_pressed("right"):
		input_dir.x += 1
	if Input.is_action_pressed("up"):
		input_dir.y += 1
	if Input.is_action_pressed("down"):
		input_dir.y -= 1
	
	# Normalize the input direction
	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()
	
	# Move in the direction the camera is facing
	global_position += input_dir.x * global_transform.basis.x * movement_speed * delta
	global_position += input_dir.y * global_transform.basis.y * movement_speed * delta
	global_position += input_dir.z * global_transform.basis.z * movement_speed * delta

# Ensure the camera stays within defined bounds
func enforce_bounds() -> void:
	global_position.x = clamp(global_position.x, x_min, x_max)
	global_position.y = clamp(global_position.y, y_min, y_max)
	global_position.z = clamp(global_position.z, z_min, z_max)
