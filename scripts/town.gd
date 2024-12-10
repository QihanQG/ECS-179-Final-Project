extends Node3D

var town_radius: float = 15.0
var show_debug_lines: bool = true 
var town_boundary_mesh: MeshInstance3D

signal town_initialized
signal boundary_updated

func _ready():
	global_position = Vector3(10.363, 1.8, 0.074)  # Increased Y value
	create_boundary_visualization()
	emit_signal("town_initialized")
	print("Town initialized at: ", global_position)

func create_boundary_visualization():
	town_boundary_mesh = MeshInstance3D.new()
	add_child(town_boundary_mesh)
	
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = town_radius
	cylinder.bottom_radius = town_radius
	cylinder.height = 5  
	
	town_boundary_mesh.mesh = cylinder
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.8, 0.8, 0.8, 0.2)  # Light gray, very transparent
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	#material.no_depth_test = true  
	
	town_boundary_mesh.material_override = material
	town_boundary_mesh.position = Vector3(0, 1, 0)

func _process(_delta):
	if show_debug_lines:
		draw_debug_visualization()

func draw_debug_visualization():
	var pos = global_position
	
	# Draw a cross at the town center
	DebugDraw3D.draw_line(
		pos + Vector3(-5, 0.1, 0),
		pos + Vector3(5, 0.1, 0),
		Color.RED
	)
	DebugDraw3D.draw_line(
		pos + Vector3(0, 0.1, -5),
		pos + Vector3(0, 0.1, 5),
		Color.BLUE
	)
	
	# Draw the boundary circle slightly above ground level
	var segments = 32
	for i in range(segments):
		var angle = (i / float(segments)) * TAU
		var next_angle = ((i + 1) / float(segments)) * TAU
		
		var start = pos + Vector3(
			cos(angle) * town_radius,
			0.1,  # Slightly above ground
			sin(angle) * town_radius
		)
		
		var end = pos + Vector3(
			cos(next_angle) * town_radius,
			0.1,
			sin(next_angle) * town_radius
		)
		
		DebugDraw3D.draw_line(start, end, Color.GREEN)

# Utility functions for other systems to use
func get_boundary_radius() -> float:
	return town_radius

func is_position_within_town(position: Vector3) -> bool:
	var distance = position.distance_to(global_position)
	return distance <= town_radius

func get_random_position_in_town() -> Vector3:
	var angle = randf() * TAU
	var distance = randf() * town_radius
	return global_position + Vector3(
		cos(angle) * distance,
		0,
		sin(angle) * distance
	)
