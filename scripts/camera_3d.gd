extends Camera3D

# Camera Properties
@export var movement_speed: float = 5
@export var mouse_sensitivity: float = 0.002
@export var zoom_speed: float = 1.0
@export var max_zoom: float  = 10.0


var is_rotating: bool = false

var current_zoom_level: float = 0.0

#not used
var target_zoom_level: float  = 0.0  
var zoom_smoothness: float = 10.0


func _ready() -> void:
	set_current(true)

# Handle input events (mouse clicks and wasd movement)
func _input(event: InputEvent) -> void:
	handle_mouse_button_events(event)
	handle_mouse_motion(event)
	handle_mouse_wheel(event)

# Handle mouse button press and release
func handle_mouse_button_events(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		start_camera_rotation()
	elif event.is_action_released("right_click"):
		stop_camera_rotation()

# Handle mouse movement for rotation
func handle_mouse_motion(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_rotating:
		rotate_camera(event.relative)

# Start camera rotation mode
func start_camera_rotation() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	is_rotating = true

# Stop camera rotation mode
func stop_camera_rotation() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	is_rotating = false

# Rotate the camera based on mouse movement
func rotate_camera(mouse_movement: Vector2) -> void:
	rotate_y(-mouse_movement.x * mouse_sensitivity)
	rotate_object_local(Vector3.RIGHT, -mouse_movement.y * mouse_sensitivity)
	
	
	
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
		
		
#not used
func handle_zoom_smooth(delta: float) -> void:
	if current_zoom_level != target_zoom_level:
		current_zoom_level = lerp(current_zoom_level, target_zoom_level, delta * zoom_smoothness)
		#Apply zoom movement
		var forward_vector = -global_transform.basis.z
		var position_change = forward_vector * (target_zoom_level - current_zoom_level) 
		global_position += position_change
	 
	

# Handle keyboard input for camera movement
func _process(delta: float) -> void:
	handle_keyboard_movement(delta)
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
