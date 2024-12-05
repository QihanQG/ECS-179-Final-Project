extends Node3D

# Town properties
var town_radius: float = 45.0  # Size of town area
var town_center: Vector3  # Central point of the town
var show_debug_lines: bool = true  # Toggle for debugging lines

# Visual representation
var town_boundary_mesh: MeshInstance3D  # Will hold our cylinder mesh

func _ready():
	# Initialize town when the node enters the scene
	town_center = Vector3(-0.006871, 2.4462, -4.35021)
	add_to_group("town")
	setup_visual_boundary()
	print("Town initialized at position: ", town_center)

func setup_visual_boundary():
	# Create a visual cylinder to represent town boundaries
	town_boundary_mesh = MeshInstance3D.new()
	add_child(town_boundary_mesh)
	
	# Create and configure the cylinder mesh
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = town_radius
	cylinder.bottom_radius = town_radius
	cylinder.height = 0.1  # Thin disk to show boundary
	
	# Apply the mesh to our MeshInstance3D
	town_boundary_mesh.mesh = cylinder
	
	# Create and configure a semi-transparent material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.0, 0.5, 1.0, 0.3)  # Semi-transparent blue
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	# Apply the material to our mesh
	town_boundary_mesh.material_override = material

func _process(_delta):
	if show_debug_lines:
		draw_town_boundaries()

func draw_town_boundaries():
	# Draw debug lines showing town boundary
	var segments = 32  # Number of line segments to draw circle
	for i in range(segments):
		# TAU is 2*PI 
		var angle = (i / float(segments)) * TAU  # Current angle
		var next_angle = ((i + 1) / float(segments)) * TAU  # Next angle
		
		# Calculate start point of line segment
		var start = Vector3(
			cos(angle) * town_radius, 
			0,                         
			sin(angle) * town_radius 
		)
		
		# Calculate end point of line segment
		var end = Vector3(
			cos(next_angle) * town_radius,
			0,
			sin(next_angle) * town_radius
		)
		
		# Draw the line segment
		DebugDraw3D.draw_line(
			town_center + start,  # Line start
			town_center + end,    # Line end 
			Color.BLUE           # Line color
		)

# Utility function to check if a position is within town boundaries
func is_within_town_bounds(position: Vector3) -> bool:
	var distance = position.distance_to(town_center)
	return distance <= town_radius

# Helper function for valid building placement
func get_valid_building_position(desired_position: Vector3) -> Vector3:
	if is_within_town_bounds(desired_position):
		return desired_position
	
	# If outside bounds, clamp to nearest valid position
	var to_position = desired_position - town_center
	to_position.y = 0  # Keep at ground level
	to_position = to_position.normalized() * min(to_position.length(), town_radius)
	
	return town_center + to_position
