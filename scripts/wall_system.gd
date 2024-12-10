extends BaseBuilding

# Wall-specific properties
var wall_segments: Array = []
var turret_mount_points: Array = []
var wall_height: float = 2.0

# Damage reduction system
var damage_reduction: float = 0.0
var upgrade_level: int = 0
var max_upgrade_level: int = 5

# Configuration
@export var num_turret_points: int = 8
var wall_radius: float

# Node references
@onready var segments_node = $WallSegments
@onready var mounts_node = $TurretMounts
@onready var town_node = get_parent()

# Wall-specific signals
signal wall_breached
signal wall_upgraded(new_level: int, damage_reduction: float)
signal turret_mounted(mount_point: Node3D)

func _ready():
	building_name = "wall"
	max_health = 1000.0
	
	# Call parent _ready() to handle base initialization
	super._ready()
	
	wall_radius = town_node.get_boundary_radius()
	
	setup_wall_system()
	create_turret_points()
	print("Wall system initialized with radius: ", wall_radius)

func setup_wall_system():
	# Create the container nodes if they don't exist
	if !segments_node:
		segments_node = Node3D.new()
		segments_node.name = "WallSegments"
		add_child(segments_node)
	
	if !mounts_node:
		mounts_node = Node3D.new()
		mounts_node.name = "TurretMounts"
		add_child(mounts_node)
	
	create_wall_segments()

func create_wall_segments():
	var segments = 16
	for i in range(segments):
		var angle = (i / float(segments)) * TAU
		var next_angle = ((i + 1) / float(segments)) * TAU
		
		var start_pos = Vector3(cos(angle) * wall_radius, 0, sin(angle) * wall_radius)
		var end_pos = Vector3(cos(next_angle) * wall_radius, 0, sin(next_angle) * wall_radius)
		
		create_wall_segment(start_pos, end_pos)

func create_wall_segment(start: Vector3, end: Vector3) -> void:
	var segment = StaticBody3D.new()
	segments_node.add_child(segment)
	
	var mesh_instance = MeshInstance3D.new()
	segment.add_child(mesh_instance)
	
	var collision_shape = CollisionShape3D.new()
	segment.add_child(collision_shape)
	
	var segment_length = start.distance_to(end)
	var segment_center = (start + end) / 2
	
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(segment_length, wall_height, 1.0)
	mesh_instance.mesh = box_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.7, 0.7, 0.7)
	mesh_instance.material_override = material
	
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(segment_length, wall_height, 1.0)
	collision_shape.shape = box_shape
	
	segment.look_at_from_position(segment_center, end, Vector3.UP)
	wall_segments.append(segment)

func create_turret_points():
	for i in range(num_turret_points):
		var angle = (i / float(num_turret_points)) * TAU
		var point_pos = Vector3(
			cos(angle) * (wall_radius - 0.5),
			wall_height / 2,
			sin(angle) * (wall_radius - 0.5)
		)
		
		var mount = Marker3D.new()
		mounts_node.add_child(mount)
		mount.global_position = point_pos
		mount.look_at(global_position, Vector3.UP)
		
		mount.set_meta("occupied", false)
		turret_mount_points.append(mount)

# Override base damage handling to include damage reduction
func take_damage(amount: float) -> void:
	var reduced_damage = amount * (1.0 - damage_reduction)
	super.take_damage(reduced_damage)

func upgrade_wall_defense() -> bool:
	if upgrade_level >= max_upgrade_level:
		return false
	
	upgrade_level += 1
	damage_reduction = upgrade_level * 0.1  # Each level reduces damage by 10%
	emit_signal("wall_upgraded", upgrade_level, damage_reduction)
	return true

func get_available_mount_point() -> Marker3D:
	for point in turret_mount_points:
		if not point.get_meta("occupied"):
			return point
	return null

func mount_turret(turret: Node3D, mount_point: Marker3D) -> bool:
	if mount_point.get_meta("occupied"):
		return false
	
	mount_point.add_child(turret)
	mount_point.set_meta("occupied", true)
	emit_signal("turret_mounted", mount_point)
	return true

# Override the base building's debug visualization
func _process(delta):
	super._process(delta)
	if Engine.is_editor_hint() or OS.is_debug_build():
		draw_debug_markers()

func draw_debug_markers():
	for point in turret_mount_points:
		var color = Color.RED if point.get_meta("occupied") else Color.GREEN
		DebugDraw3D.draw_line(
			point.global_position,
			point.global_position + Vector3(0, 2, 0),
			color
		)

# Public API
func get_damage_reduction() -> float:
	return damage_reduction

func get_upgrade_level() -> int:
	return upgrade_level

func can_upgrade() -> bool:
	return upgrade_level < max_upgrade_level
