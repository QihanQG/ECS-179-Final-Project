extends Node3D

var movement_speed: float = 5
var bindkeys: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#add_to_group("enemies")
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_pressed("bind_keys"):
		if bindkeys:
			bindkeys = false
		else:
			bindkeys = true

	if bindkeys == true:
		handle_keyboard_movement(delta)
	
	
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
