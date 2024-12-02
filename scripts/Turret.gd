class_name Turret
extends Object


#Required Components"
var parent_node: Node
var rotation_area: Node3D 
var detection_area: Area3D   #radius detection
var spawn_point: Marker3D #projectile spawn point
var projectile_scene: PackedScene



@export var rotation_speed: float = 50.0
@export var barrel_length: float = 1.2
@export var projectile_speed: float = 120.0
@export var fire_rate: float = 0.4
#@export var rotation_duration: float = 5.0
@export var lock_on_till_death: bool  #lock onto one target until it's dead
@export var debug_mode : bool = true


#@onready var turret_vision_mesh: MeshInstance3D = $TurretRotation/detect_visual  #the mesh of the turret vision cone or "vision"


var max_lock_on_angle: float = 90.0


#var is_rotating: bool = true
var can_shoot: bool = true
var shoot_timer: Timer
var rotate_timer: Timer
var potential_targets: Array = []
var current_target  = null

var in_turret_vison: bool = false

var debug_labels: Dictionary = {}
var info_label: Label3D  # For main turret info


#target normal
enum TargetMode {NORMAL, PREDICTED_AIM}
@export var target_mode: TargetMode = TargetMode.PREDICTED_AIM



func initialize(parent_node, rotation_area: Node3D, detection_area: Area3D, spawn_point: Marker3D, projectile_scene: PackedScene):
	self.parent_node = parent_node
	self.rotation_area = rotation_area
	self.detection_area = detection_area
	self.spawn_point = spawn_point
	self.projectile_scene = projectile_scene
	
	lock_on_till_death = lock_on_till_death
	
	# Connect signals using Callable
	detection_area.connect("body_entered", Callable(self, "_on_detection_area_body_entered"))
	detection_area.connect("body_exited", Callable(self, "_on_detection_area_body_exited"))
	
	# Initialize shoot timer
	shoot_timer = Timer.new()
	shoot_timer.wait_time = fire_rate
	shoot_timer.one_shot = true
	shoot_timer.connect("timeout", Callable(self, "_on_shoot_timer_timeout"))
	rotation_area.add_child(shoot_timer)
	
	# Initialize debug labels if debug_mode is enabled
	if debug_mode:
		setup_debug()
	# Initialize debug labels if debug_mode is enabled



func process(delta):
	if debug_mode:
		draw_angle_boundaries() 
	aim_mode()

func setup_debug():
	
	#debug_statements()
	#debug lines/labels
	
	#debug_info
	info_label = Label3D.new()
	info_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	info_label.font_size = 16
	info_label.position = Vector3(0, 2, 0)  # Above turret
	info_label.modulate = Color.WHITE
	rotation_area.add_child(info_label)
	
	var label_colors = {
		"forward": Color.YELLOW,
		"target": Color.RED,
		"cross": Color.GREEN
	}
	
	for label_name in label_colors:
		var label = Label3D.new()
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.font_size = 16
		label.modulate = label_colors[label_name]
		debug_labels[label_name] = label
		parent_node.add_child(label)


#For handling different aim modes
func aim_mode() -> void:
	
	if lock_on_till_death:
		if current_target and is_instance_valid(current_target):
			aim_at_target(current_target.global_position)
			if can_shoot:
				shoot()
		else:
			# Current target is invalid or null, find a new target
			if not potential_targets.is_empty():
				current_target = find_closest_target()
				if current_target:
					aim_at_target(current_target.global_position)
					if can_shoot:
						shoot()
	else:
		if not potential_targets.is_empty():
			current_target = find_closest_target()
			if current_target:
				aim_at_target(current_target.global_position)
				if can_shoot:
					shoot()
	

	

func _on_detection_area_body_entered(body: Node3D) -> void:
	#print("Body entered: ", body.name)
	if body.is_in_group("enemies"):
		potential_targets.append(body)
		print(body.name)
		
		#_debug_statements_body_entered()
	#print(body.name)

func _on_detection_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("enemies"):
		potential_targets.erase(body)
		if body == current_target:
			current_target = null


#not used currently
#func _is_in_vision_cone(target_position: Vector3) -> bool:
	## Use vision cone position instead of turret base
	#var to_target = target_position - turret_vision_mesh.global_position
	#
	## Get forward direction from transform
	#var cone_forward = -$TurretRotation.global_transform.basis.z
	#
	#if to_target.length() > turret_vision_mesh.mesh.height:
		#return false
		#
	## Ignore Y component
	#var flat_to_target = Vector3(to_target.x, 0, to_target.z).normalized()
	#var flat_forward = Vector3(cone_forward.x, 0, cone_forward.z).normalized()
	#
	## Clamp dot product
	#var dot_product = clampf(flat_forward.dot(flat_to_target), -1.0, 1.0)
	#var angle_differences = rad_to_deg(acos(dot_product))
	#
	#var cone_angle = rad_to_deg(atan2(turret_vision_mesh.bottom_radius, turret_vision_mesh.height))
#
	##print(angle_differences)
	#return angle_differences <= cone_angle


#To-Do
func _on_turret_vision_body_entered(body: Node3D) -> void:
	in_turret_vison = true

func _on_turret_vision_body_exited(body: Node3D) -> void:
	in_turret_vison = false


	
func aim_at_target(target_position:Vector3):
	
	var to_target: Vector3

	match target_mode:
		TargetMode.NORMAL:
			to_target = target_position - rotation_area.global_position
		TargetMode.PREDICTED_AIM:
			var aim_position = aim_at_predicted_target(target_position)
			to_target = aim_position - rotation_area.global_position
		
	#only XZ plane projection (ignoring Y component)
	var to_target_xz = Vector3(to_target.x, 0, to_target.z)
	var to_target_xz_normalized = to_target_xz.normalized()
	
	
	var current_direction = get_forward_direction(rotation_area.rotation)
	var current_direction_xz = Vector3(current_direction.x, 0, current_direction.z).normalized()

	#Use dot product to get the angle.
	var dot_product = current_direction_xz.dot(to_target_xz_normalized)
	dot_product = clamp(dot_product, -1.0, 1.0) 
	var angle_diff = rad_to_deg(acos(dot_product))

	# angle_diff > 0 mean the turret barrel is not facing the enemies/objects
	if angle_diff <= max_lock_on_angle:  
		if angle_diff > 0.1:
			#Positive y = rotate counterclockwise around Y axis, Negative y = rotate clockwise around Y axis.
			var cross_product = current_direction_xz.cross(to_target_xz_normalized)
			var rotation_direction = 1 if cross_product.y > 0 else -1
			
			var smoothing_factor: float = 5.0
			var rotation_amount = rotation_speed * parent_node.get_process_delta_time()
			rotation_amount = lerp(0.0, rotation_amount, smoothing_factor * parent_node.get_process_delta_time())
			rotation_area.rotate_y(rotation_direction * rotation_amount)
			if debug_mode:	
				draw_aim_debug(to_target_xz_normalized, current_direction_xz, cross_product, angle_diff)



func aim_at_predicted_target(target_position: Vector3) -> Vector3:
	if not current_target or not (current_target is CharacterBody3D):
		return target_position
		
	var target_velocity = current_target.velocity
	var start_pos = parent_node.global_position
	var to_target = target_position - start_pos

	# solve equation coefficients for interception
	var a = target_velocity.length_squared() - (projectile_speed * projectile_speed)
	var b = 2 * target_velocity.dot(to_target)
	var c = to_target.length_squared()
	
	var time_to_target: float
	
	if abs(a) < 0.001:  # target speed close to projectile speed
		if abs(b) > 0.001: 
			time_to_target = -c / b #Lienar solution
		else:
			#if both a and b ≈ 0
			time_to_target = to_target.length() / projectile_speed
	else:
		
		#solve quadratic equation.
		var discriminant = b * b - 4 * a * c
		
		if discriminant < 0:
			# No real solution as target too fast or unreachable
			time_to_target = to_target.length() / projectile_speed
		else:
			#intercept times 
			var t1 = (-b + sqrt(discriminant)) / (2 * a)
			var t2 = (-b - sqrt(discriminant)) / (2 * a)
			
			#choose the smallest positive value
			if t1 > 0 and t2 > 0:
				time_to_target = min(t1, t2)
			elif t1 > 0:
				time_to_target = t1
			elif t2 > 0:
				time_to_target = t2
			else:
				time_to_target = to_target.length() / projectile_speed
	
	# Calculate predicted position
	var predicted_position = target_position + (target_velocity * time_to_target)
	
	# Add debug visualization
	self.last_intercept_time = time_to_target
	self.last_predicted_position = predicted_position
	
	return predicted_position



func find_closest_target():
	#Use for when Lock_on_til_death is true, it will stay lock on to that target until it's dead
	if lock_on_till_death and current_target and is_instance_valid(current_target):
		return current_target

	var closest_target = null
	var closest_distance = INF
	
	#temporary arrau  for targets to remove
	var targets_to_remove = []
	for target in potential_targets:
		# Check if target is still valid
		if is_instance_valid(target) and target != null:
			var distance = (target.global_position - parent_node.global_position).length()
			if distance < closest_distance:
				closest_distance = distance
				closest_target = target
		else:
			# target is dead, add to the temp target remove array
			targets_to_remove.append(target)
	
	#then remove it the target is dead.
	for dead_target in targets_to_remove:
		potential_targets.erase(dead_target)
	return closest_target


func _on_shoot_timer_timeout():
	can_shoot = true



func shoot():
	var projectile = projectile_scene.instantiate()
	parent_node.add_child(projectile)

	# Set position first
	projectile.global_position = spawn_point.global_position
	var current_rotation = spawn_point.global_rotation
	
	projectile.global_rotation = spawn_point.global_rotation
	
	# Calculate the direction the barrel is pointing 
	var forward_direction = get_forward_direction(current_rotation)
	#var forward_direction = spawn_point.global_transform.basis.z
	
	if projectile is RigidBody3D:
		# Apply velocity immediately after setting position
		projectile.linear_velocity = forward_direction * projectile_speed
		
	can_shoot = false
	shoot_timer.start()




#only use for testing	
func get_forward_direction(euler_angles: Vector3) -> Vector3:
	var rx = euler_angles.x
	var ry = euler_angles.y
	
	#x,y,z components of forward direction vector
	#i.e forward_direction = Rx * (Ry * [0,0,1]), this is give you forward or the 3rd column vector after you done the matrix multiplication
	var forward_x = sin(ry)
	var forward_y = -sin(rx) * cos(ry)
	var forward_z  = cos(rx) * cos(ry)
	
	#[0,0,-1] is forward on godot, but because of the orientation of models i built, i didn't make it negative.
	var forward_vector = Vector3(forward_x,forward_y,forward_z).normalized()
	return forward_vector
		



#Rx =| 1   0      0      |
	#| 0   cos(x) -sin(x)|
	#| 0   sin(x)  cos(x)|
	#
#Ry =| cos(y)  0  sin(y)|
	#| 0       1  0     |
	#|-sin(y)  0  cos(y)|
	  #
#Compute: Rx * (Ry * [0,0,1]) where [0,0,1] is the forward direction or unit vector Z
	#
#Ry  *  (0,0,1)  =	 | cos(y)  0  sin(y)| |0|   |sin(y) |
					#| 0       1  0     | |0| = |  0    | 
					#|-sin(y)  0  cos(y)| |1|   |cos(y) |
					#
#Rx * (Ry * [0,0,1])  
#
#Rx * (Ry * [0,0,1]) =	| 1   0      0     | |sin(y) |     |     sin(y)     |
						#| 0   cos(x) -sin(x)| |  0    | = |-sin(x)cos(y)   |
						#| 0   sin(x)  cos(x)| |cos(y) |   | cos(x)cos(y)   |
						#
#So the final vector:
	#
#[     sin(y)      ] = x 
#[-sin(x)cos(y)    ] = y
#[ cos(x)cos(y)    ] = z 


	






########################################Debugs purpose############################


func draw_angle_boundaries():
	if not debug_mode:
		return
		
	var start_pos = rotation_area.global_position
	var line_length = 20.0
	var current_dir = get_forward_direction(rotation_area.rotation)
	
	# Draw forward vector (yellow)
	var forward_end = start_pos + current_dir * 3.0
	DebugDraw3D.draw_arrow(
		start_pos,
		forward_end,
		Color.YELLOW,
		0.1
	)
	
	# Draw left and right angle boundaries (red)
	var left_angle = deg_to_rad(-max_lock_on_angle)
	var right_angle = deg_to_rad(max_lock_on_angle)
	
	# Calculate boundary vectors by rotating the forward vector
	var left_boundary = current_dir.rotated(Vector3.UP, left_angle)
	var right_boundary = current_dir.rotated(Vector3.UP, right_angle)
	
	# left boundary
	DebugDraw3D.draw_line(
		start_pos,
		start_pos + left_boundary * line_length,
		Color.RED
	)
	
	# right boundary
	DebugDraw3D.draw_line(
		start_pos,
		start_pos + right_boundary * line_length,
		Color.RED
	)
	
	# Draw arc segments between boundaries
	var segments = 20
	var prev_point = start_pos + left_boundary * line_length
	for i in range(1, segments + 1):
		var t = float(i) / segments
		var angle_t = left_angle + (right_angle - left_angle) * t
		var current_vector = current_dir.rotated(Vector3.UP, angle_t)
		var current_point = start_pos + current_vector * line_length
		
		DebugDraw3D.draw_line(
			prev_point,
			current_point,
			Color(1, 0, 0, 0.5)
		)
		prev_point = current_point










var current_rotation_direction: String = ""
var prev_cross_y: float = 0.0
var cross_product_label: String 

var last_intercept_time: float = 0.0
var last_predicted_position: Vector3 = Vector3.ZERO

func draw_aim_debug(to_target: Vector3, current_dir: Vector3, cross: Vector3, angle: float):
	
	var start_pos = rotation_area.global_position
	var line_length = 20.0  # Length of the visualization lines

	var forward_end = start_pos + current_dir * 3.0
	DebugDraw3D.draw_arrow(
		start_pos,
		forward_end,
		Color.YELLOW,
		0.1
	)
	
	debug_labels["forward"].position = forward_end - start_pos + Vector3(0, 0.4, 0)
	debug_labels["forward"].text = "Forward vector"
	

	if sign(cross.y) != sign(prev_cross_y) and abs(cross.y) > 0.01:
		current_rotation_direction = "Rotating " + ("Counterclockwise" if cross.y > 0 else "Clockwise")
		cross_product_label = "Cross Product vector y value:  "  + str(cross.y)
	
	
	# Fixed position up and forward
	var arrow_start = start_pos + Vector3(0, 3, 0)
			
	var arrow_direction: Vector3
	
	
	if  cross.y >= 0.01:
			arrow_direction = Vector3(0, 1, 0)
			
	elif cross.y <= -0.01:
			arrow_direction = Vector3(0, -1, 0)
	var arrow_end = arrow_start + arrow_direction
			

	DebugDraw3D.draw_arrow(
		arrow_start,
		arrow_end,
		Color.GREEN,
		0.1
			)
	debug_labels["cross"].position = ((Vector3(0,1,0) + arrow_start) - start_pos)  + Vector3(0, 0.9, 0)
	debug_labels["cross"].text = cross_product_label
	

	prev_cross_y = cross.y

	# Update main info label
	
	# Update info label
	if current_target and is_instance_valid(current_target):
		# Draw line from current to predicted position
		DebugDraw3D.draw_line(
			current_target.global_position,
			last_predicted_position,
			Color.STEEL_BLUE,
			0.1
		)
		
		# Draw sphere at predicted position ~roughly
		DebugDraw3D.draw_sphere(
			last_predicted_position,
			0.5,  # Radius
			Color.INDIGO
		)
	
	# Update info label with all debug information
	var distance = (current_target.global_position - start_pos).length() if current_target else 0.0
	var target_speed = current_target.velocity.length() if current_target else 0.0
	info_label.text = (
		"Angle to target: %.1f°\n" +
		"Lock-on range: ±%.1f°\n" +
		"Distance: %.1f\n" +
		"Target Speed: %.1f\n" +
		"Intercept Time: %.2f s\n" +
		"%s\n" +
		"Lock-on status: %s"
	) % [
		angle,
		max_lock_on_angle,
		distance,
		target_speed,
		last_intercept_time,
		current_rotation_direction,
		"Locked" if angle <= max_lock_on_angle else "Out of range"
	]




func _debug_statements_body_entered() -> void:

	pass
	#print("Detected node: Name =", body.name, ", Path =", body.get_path(), ", Type =", body.get_class())
	#print("\n=== DETECTION DEBUG ===")
	#print("Enemy detected:", body.name)
	#print("Enemy position:", body.global_position)
	#print("Distance to turret:", body.global_position.distance_to(global_position))
	#print("Enemy relative to vision cone:", body.global_position - turret_vision_mesh.global_position)
	
	#var to_enemy = (body.global_position - turret_vision_mesh.global_position).normalized()
	#var cone_forward = -turret_vision_mesh.global_transform.basis.y  # Because of -90 degree X rotation
	#var angle = rad_to_deg(acos(to_enemy.dot(cone_forward)))
	#print("Angle to vision cone axis:", angle)
	#print("Vision cone forward direction:", cone_forward)
		




#func debug_statements() -> void:
#
	#print("vision cone top radius: ",turret_vision_mesh.mesh.top_radius)
	#print("vision cone bottom radius: ", turret_vision_mesh.mesh.bottom_radius)
	#print("vision cone height ", turret_vision_mesh.mesh.height)
	#print("vision cone position ", turret_vision_mesh.global_position)
	#print("vision cone rotation ", turret_vision_mesh.global_rotation)
	#
	#
		## Debug node hierarchy
	#print("\n=== FULL NODE HIERARCHY ===")
	#print_node_hierarchy(self, 0)
	#
	#print("\n=== DETAILED NODE PROPERTIES ===")
	## Debug turret rotation node
	#print("\nTurret Rotation Node:")
	#if has_node("TurretRotation"):
		#var turret_rotation = $TurretRotation
		#print("- Position:", turret_rotation.global_position)
		#print("- Rotation:", turret_rotation.global_rotation)
		#print("- Scale:", turret_rotation.scale)
	#
	## Debug vision cone properties
	#print("\nVision Cone Properties:")
	#if turret_vision_mesh:
		#print("- Mesh Position:", turret_vision_mesh.global_position)
		#print("- Mesh Local Position:", turret_vision_mesh.position)
		#print("- Mesh Global Rotation:", turret_vision_mesh.global_rotation)
		#print("- Mesh Local Rotation:", turret_vision_mesh.rotation)
		#print("- Mesh Scale:", turret_vision_mesh.scale)
	#
	## Debug detection area
	#print("\nDetection Area Properties:")
	#if detection_area:
		#print("- Position:", detection_area.global_position)
		#print("- Rotation:", detection_area.global_rotation)
		#print("- Scale:", detection_area.scale)
		#if detection_area.get_child_count() > 0:
			#for child in detection_area.get_children():
				#if child is CollisionShape3D:
					#print("- Collision Shape Type:", child.shape.get_class())
					## If it's a cylinder shape
					#if child.shape is CylinderShape3D:
						#print("  - Height:", child.shape.height)
						#print("  - Radius:", child.shape.radius)
	#
	## Debug spawn point
	#print("\nProjectile Spawn Point:")
	#if spawn_point:
		#print("- Global Position:", spawn_point.global_position)
		#print("- Local Position:", spawn_point.position)
		#print("- Global Rotation:", spawn_point.global_rotation)
		#print("- Local Rotation:", spawn_point.rotation)	


	
