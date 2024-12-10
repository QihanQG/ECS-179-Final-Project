extends StaticBody3D

class_name BaseBuilding

# Core building properties
@export var building_name: String = "base"
@export var max_health: float = 100.0
var current_health: float
var is_operational: bool = true

# Penguin workforce management
var assigned_penguins: int = 0
var max_penguins: int = 5

# References
var game_manager: Node
var visual_mesh: MeshInstance3D
var collision_shape: CollisionShape3D

# Signals
signal health_changed(current: float, maximum: float)
signal building_destroyed
signal penguin_count_changed(new_count: int)
signal operational_status_changed(is_operational: bool)

func _ready():
	initialize_building()
	setup_game_manager()
	add_to_group("buildings")

func initialize_building():
	current_health = max_health
	#setup_visual_components()
	print("Building initialized: ", building_name)
	emit_signal("health_changed", current_health, max_health)

func setup_game_manager():
	game_manager = get_node("/root/World/GameManager")
	if !game_manager:
		push_error("GameManager not found for building: " + building_name)
		return

func take_damage(amount: float) -> void:
	if !is_operational:
		return
		
	current_health = max(0, current_health - amount)
	emit_signal("health_changed", current_health, max_health)
	
	update_appearance_on_damage()
	
	if current_health <= 0:
		on_destroyed()

func update_appearance_on_damage():
	if !visual_mesh:
		return
		
	var health_percentage = current_health / max_health
	var material = visual_mesh.material_override
	if material:
		# Redden the building as it takes damage
		material.albedo_color = Color(
			1.0,
			health_percentage,
			health_percentage,
			1.0
		)

func on_destroyed() -> void:
	is_operational = false
	emit_signal("building_destroyed")
	emit_signal("operational_status_changed", false)
	handle_destruction()

func handle_destruction() -> void:
	# Override in child classes for specific destruction behavior
	pass

func assign_penguins(count: int) -> bool:
	if count < 0 or count > max_penguins:
		return false
	
	assigned_penguins = count
	emit_signal("penguin_count_changed", assigned_penguins)
	on_penguin_assignment_changed()
	return true

func on_penguin_assignment_changed() -> void:
	# Override in child classes to implement specific penguin effects
	pass

# Virtual methods for child classes
func get_building_type() -> String:
	return building_name

func get_efficiency() -> float:
	# Base efficiency calculation
	return 1.0 + (assigned_penguins * 0.2)

# Public API for interaction
func get_health_percentage() -> float:
	return (current_health / max_health) * 100.0

func get_assigned_penguins() -> int:
	return assigned_penguins

func can_assign_more_penguins() -> bool:
	return assigned_penguins < max_penguins

func get_available_penguin_slots() -> int:
	return max_penguins - assigned_penguins

func is_alive() -> bool:
	return current_health > 0

func can_interact() -> bool:
	return is_operational

# Debug visualization
func _process(_delta: float) -> void:
	if Engine.is_editor_hint() or OS.is_debug_build():
		draw_debug_info()

func draw_debug_info() -> void:
	if !is_operational:
		return
		
	var pos = global_position
	var height = 4.0
	
	# Draw building status
	DebugDraw3D.draw_line(
		pos,
		pos + Vector3(0, height, 0),
		Color(1.0, current_health / max_health, 0, 1.0)
	)
	
	# Draw penguin assignment indicator
	if assigned_penguins > 0:
		var penguin_color = Color(0, 1, 0, 0.5)
		DebugDraw3D.draw_sphere(
			pos + Vector3(0, height/2, 0),
			0.3 * assigned_penguins,
			penguin_color
		)

# Now set shape by inspector
func setup_visual_components():
	# Base mesh setup - override in child classes for specific appearances
	visual_mesh = MeshInstance3D.new()
	add_child(visual_mesh)
	
	var mesh = BoxMesh.new()
	mesh.size = Vector3(3, 3, 3)  # Default size
	visual_mesh.mesh = mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.7, 0.7, 0.7)
	visual_mesh.material_override = material
	
	# Collision shape setup
	collision_shape = CollisionShape3D.new()
	add_child(collision_shape)
	
	var shape = BoxShape3D.new()
	shape.size = Vector3(3, 3, 3)
	collision_shape.shape = shape
