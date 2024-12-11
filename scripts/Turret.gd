class_name Turret
extends Object

var parent_node: Node
var rotation_area: Node3D
var mount_rotation_pitch: Node3D
var detection_area: Area3D
var spawn_points: Array[Marker3D] = []
var projectile_scene: PackedScene

var target_position: Vector3 
var barrel_ref: Vector3  # barrel reference point, i.e the barrel position
var enemies: String = "enemies"

var damage: int = 10.0
var rotation_speed: float = 20.0
var projectile_speed: float = 120.0
var lock_on_till_death: bool = true
var debug_mode: bool = true

var max_lock_on_angle: float = 90.0
var max_pitch_up: float =  -60  
var max_pitch_down: float = 20

#private variables
var _fire_rate: float = 0.8
var _detection_radius: float

var can_shoot: bool = true
var shoot_timer: Timer
var potential_targets: Array = []
var current_target = null

# Debug visualization
var debug_labels: Dictionary = {}
var info_label: Label3D
var current_rotation_direction: String = ""
var prev_cross_y: float = 0.0
var cross_product_label: String
var last_intercept_time: float = 0.0

# Aim modes
enum TargetMode {NORMAL, PREDICTED_AIM}
@export var target_mode: TargetMode = TargetMode.PREDICTED_AIM

# Fire rate property
var fire_rate: float:
	get: return _fire_rate
	set(value):
		_fire_rate = value
		if shoot_timer:
			shoot_timer.wait_time = value
			
var detection_shape: CapsuleShape3D

var detection_radius: float:
	get:
		return _detection_radius
	set(value):
		_detection_radius = value
		if detection_shape:
			detection_shape.radius = value




func initialize(parent_node, rotation_area: Node3D, mount_rotation_pitch:Node3D, detection_area: Area3D, spawn_points: Array[Marker3D], projectile_scene: PackedScene, barrel_ref: Node3D = null):
	
	if barrel_ref:
		self.barrel_ref = barrel_ref.global_position

	self.parent_node = parent_node
	self.rotation_area = rotation_area
	self.mount_rotation_pitch = mount_rotation_pitch
	self.detection_area = detection_area
	self.spawn_points = spawn_points
	self.projectile_scene = projectile_scene
	self.damage = damage
	
	# Initialize detection radius
	var collision_shape = detection_area.get_children()
	for child in detection_area.get_children():
		if child is CollisionShape3D and child.shape is CapsuleShape3D:
			detection_shape = child.shape
			_detection_radius = detection_shape.radius  
			break
	
	# Connect signals
	detection_area.connect("body_entered", Callable(self, "_on_detection_area_body_entered"))
	detection_area.connect("body_exited", Callable(self, "_on_detection_area_body_exited"))
	
	# Initialize shoot timer
	shoot_timer = Timer.new()
	shoot_timer.wait_time = fire_rate
	shoot_timer.one_shot = true
	shoot_timer.connect("timeout", Callable(self, "_on_shoot_timer_timeout"))
	parent_node.add_child(shoot_timer)
	
	if debug_mode:
		setup_debug()


func process(delta):
	if debug_mode:
		draw_angle_boundaries()
	aim_mode()


func _on_detection_area_body_entered(body: Node3D) -> void:
	#print("Body entered: ", body.name)
	if body.is_in_group(enemies):
		potential_targets.append(body)
		print(body.name)
		
		#_debug_statements_body_entered()
	#print(body.name)

func _on_detection_area_body_exited(body: Node3D) -> void:
	if body.is_in_group(enemies):
		potential_targets.erase(body)
		if body == current_target:
			current_target = null



func aim_mode() -> void:
	if current_target and is_instance_valid(current_target):
		var target_position = current_target.global_position
		
		# Determine the position to aim at based on the target mode
		var aim_position = target_position
		if target_mode == TargetMode.PREDICTED_AIM:
			aim_position = calculate_predicted_position(target_position)
		
		var angles = calculate_angles(aim_position)
		
		if angles["in_range"]:
			if lock_on_till_death:
				aim_at_target(aim_position)  
				if can_shoot:
					shoot()
			else:
				if not potential_targets.is_empty():
					current_target = find_closest_target()
					if current_target:
						# Remove ternary operator and use if-else
						if target_mode == TargetMode.PREDICTED_AIM:
							aim_position = calculate_predicted_position(current_target.global_position)
						else:
							aim_position = current_target.global_position
						
						aim_at_target(aim_position)
						if can_shoot:
							shoot()
	else:
		if not potential_targets.is_empty():
			current_target = find_closest_target()

			

#old stuff /mostly use for debugs
func orientations_to_target(target_position: Vector3) -> Dictionary:
	# Calculate direction to target based on mode
	var to_target: Vector3
	match target_mode:
		TargetMode.NORMAL:
			to_target = target_position - rotation_area.global_position
		TargetMode.PREDICTED_AIM:
			var aim_position = calculate_predicted_position(target_position)
			to_target = aim_position - rotation_area.global_position
	
	# Only XZ plane projection (ignoring Y component)
	var to_target_xz = Vector3(to_target.x, 0, to_target.z).normalized()
	
	# Only Y component
	var to_target_y = Vector3(0, to_target.y, 0).normalized()
	
	# Get the turret forward direction/vector o
	var current_direction = get_forward_direction_yaw_only(rotation_area.rotation)
	
	# Current direction ignoring Y
	var current_direction_xz = Vector3(current_direction.x, 0, current_direction.z).normalized()
	
	var current_direction_y = Vector3(0, current_direction.y, 0).normalized()
	
	return {
		"to_target": to_target,                      # Full 3D vector to target
		"to_target_xz": to_target_xz,                # Ignore Y (height)
		"to_target_y": to_target_y,                  # Get the direction of Y component only
		"current_direction": current_direction,      # Full 3D current direction
		"current_direction_xz": current_direction_xz,# Ignore Y direction
		"current_direction_y": current_direction_y   # Only Y direction
	}



#Mostly use for debuggins
func calculate_angles(target_position: Vector3) -> Dictionary:
	var directions = orientations_to_target(target_position)
	
	# Calculate yaw (horizontal) angles
	var target_dir_xz = directions["to_target_xz"]
	var current_direction_xz = directions["current_direction_xz"]
	var dot_product_yaw = current_direction_xz.dot(target_dir_xz)
	dot_product_yaw = clamp(dot_product_yaw, -1.0, 1.0) 
	var yaw_angle = rad_to_deg(acos(dot_product_yaw))
	
	# Calculate pitch (vertical) angles
	var to_target = directions["to_target"]
	var horizontal_distance = Vector2(to_target.x, to_target.z).length()
	
	# Current and target pitch
	var current_pitch = rad_to_deg(atan2(-directions["current_direction"].y, 
								  Vector2(directions["current_direction"].x, 
										directions["current_direction"].z).length()))
	var pitch_angle = rad_to_deg(atan2(to_target.y, horizontal_distance))
	var pitch_diff = pitch_angle - current_pitch
	
	# Calculate total 3D angle
	var target_dir = directions["to_target"].normalized()
	var current_dir = directions["current_direction"]
	var dot_product_3d = current_dir.dot(target_dir)
	dot_product_3d = clamp(dot_product_3d, -1.0, 1.0)
	var total_angle = rad_to_deg(acos(dot_product_3d))
	
	# Return both absolute angles and differences
	return {
		# Absolute angles
		"yaw_angle": yaw_angle,
		"pitch_angle": pitch_angle,
		"total_angle": total_angle,
		
		# Differences (how far to turn)
		"yaw_diff": yaw_angle,
		"pitch_diff": pitch_diff,
		"total_diff": total_angle,
		
		# Range checks
		"yaw_in_range": yaw_angle <= max_lock_on_angle,
		"pitch_in_range": pitch_angle >= max_pitch_down and pitch_angle <= max_pitch_up,
		"in_range": total_angle <= max_lock_on_angle,
		
		# Distance
		"horizontal_distance": horizontal_distance
	}





func compute_aim_angles_with_offset(target_pos: Vector3) -> Dictionary:
	var pivot_body = rotation_area.global_position
	var pivot_head = mount_rotation_pitch.global_position
	
	# Calculate Yaw (horizontal rotation) and  Determine the vector to align the turret with the target
	var horizontal_alignment_vector = pivot_body - (target_pos - pivot_body)
	horizontal_alignment_vector.y = pivot_body.y   # Ignore the vertical component Y for horizontal rotation

	
	var displacement_to_target_vertical = target_pos - pivot_head
	# Horizontal Distance = sqrt(x^2 + z^2) (flat distance on the ground).
	var target_horizontal_distance = Vector2(displacement_to_target_vertical.x, displacement_to_target_vertical.z).length()
	var target_vertical_distance = displacement_to_target_vertical.y
	var target_pitch_angle = atan2(target_vertical_distance, target_horizontal_distance)
	
	# when barrel reference point is provided
	if barrel_ref != Vector3.ZERO:
		var barrel_offset = barrel_ref - pivot_head
		target_vertical_distance = displacement_to_target_vertical.y - barrel_offset.y
		target_pitch_angle = atan2(target_vertical_distance, target_horizontal_distance)
	
	target_pitch_angle = -target_pitch_angle  
	
	return {
		"horizontal_alignment": horizontal_alignment_vector,
		"pitch_angle": target_pitch_angle,
		"horizontal_distance": target_horizontal_distance,
		"vertical_distance": target_vertical_distance
	}

func aim_at_target(target_pos: Vector3):
	
	var delta = parent_node.get_process_delta_time()

	# If there is a current target, estimate its future position using simple linear prediction
	if current_target:
		var target_velocity = get_target_velocity(current_target)
		if target_velocity != Vector3.ZERO:
			# Vector from turret to target's current position
			
			var displacement_to_target = target_pos - rotation_area.global_position
			var target_distance = displacement_to_target.length()
			
			# Time required for the projectile to reach the target
			var time_to_intercept = target_distance / projectile_speed
			
			# Predicted future position of the target
			target_pos += target_velocity * time_to_intercept
			
	var aim_info = compute_aim_angles_with_offset(target_pos)

	# Create a transform matrix that looks at the target position and apply yaw rotation
	var target_orientation_transform = rotation_area.global_transform.looking_at(aim_info["horizontal_alignment"])
	var target_orientation_basis = target_orientation_transform.basis
	var interpolated_yaw_basis = rotation_area.global_transform.basis.slerp(target_orientation_basis, rotation_speed * delta)
	rotation_area.global_transform.basis = interpolated_yaw_basis

	# Calculate Pitch (vertical rotation) : Vector from the turret's vertical mount to the target's position

	#Apply pitch rotation
	var target_pitch_angle = clamp(aim_info["pitch_angle"], deg_to_rad(max_pitch_up), deg_to_rad(max_pitch_down))
	var current_pitch_rotation = mount_rotation_pitch.rotation.x
	mount_rotation_pitch.rotation.x = lerp_angle(current_pitch_rotation, target_pitch_angle, rotation_speed * delta)
	
	if debug_mode:
		update_debug_info(target_pos)




func get_target_velocity(target: Node3D) -> Vector3:
	if target is RigidBody3D:
		return target.linear_velocity
	elif target is CharacterBody3D:
		return target.velocity
	elif target is StaticBody3D:
		return Vector3.ZERO
	elif target.has_property("velocity"):
		return target.velocity
	elif target.has_method("get_velocity"):
		return target.get_velocity()
	elif target is Node3D and target.has_property("velocity"):
		return target.velocity
	else:
		return Vector3.ZERO  




func calculate_predicted_position(target_position: Vector3) -> Vector3:
	# Return the target position directly if there's no target
	if not current_target:
		return target_position

	# Retrieve the target's velocity
	var target_velocity = get_target_velocity(current_target)

	# If the target is stationary, return the current position
	if target_velocity == Vector3.ZERO:
		return target_position

	var turret_position = rotation_area.global_position
	var relative_target_position = target_position - turret_position  # Vector from turret to target
	var target_speed_squared = target_velocity.length_squared()
	var projectile_speed_squared = projectile_speed * projectile_speed

	# Quadratic equation: a * t^2 + b * t + c = 0
	var a = target_speed_squared - projectile_speed_squared            
	var b = 2 * target_velocity.dot(relative_target_position)          
	var c = relative_target_position.length_squared()                  

	# Discriminant: Δ = b^2 - 4 * a * c
	var discriminant = b * b - 4 * a * c

	# Initialize intercept_time
	var intercept_time: float

	# Solve the quadratic equation for t (time-to-target)
	if abs(a) < 0.001:  # Handle linear case when a is nearly zero
		if abs(b) > 0.001:
			intercept_time = -c / b  # Linear solution: t = -c / b
		else:
			intercept_time = relative_target_position.length() / projectile_speed  # Simple aim
	else:
		if discriminant < 0:  # No real solutions
			intercept_time = relative_target_position.length() / projectile_speed  # Simple aim
		else:
			# Roots of the quadratic equation
			var sqrt_discriminant = sqrt(discriminant)
			var t1 = (-b + sqrt_discriminant) / (2 * a)  # First root
			var t2 = (-b - sqrt_discriminant) / (2 * a)  # Second root

			# Select the smallest positive root
			if t1 > 0 and t2 > 0:
				intercept_time = min(t1, t2)
			elif t1 > 0:
				intercept_time = t1
			elif t2 > 0:
				intercept_time = t2
			else:
				intercept_time = relative_target_position.length() / projectile_speed  # Simple aim

	# Scale the intercept time to compensate for prediction delays
	var prediction_scale_factor = 2.0
	intercept_time *= prediction_scale_factor

	var max_intercept_time = 5.0  # Maximum allowed time for prediction
	intercept_time = clamp(intercept_time, 0.0, max_intercept_time)

	# Predicted position = current target position + (velocity * intercept time)
	var predicted_position = target_position + (target_velocity * intercept_time)

	# Return the predicted position
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
	for spawn_point in spawn_points:
		var projectile = projectile_scene.instantiate()
		parent_node.add_child(projectile)
		projectile.global_position = spawn_point.global_position
		
		var rotation_vector = Vector3(mount_rotation_pitch.global_rotation.x, rotation_area.global_rotation.y, 0 )
		
		var forward_direction = get_forward_direction_from_yaw_and_pitch(rotation_vector)
		
		projectile.global_rotation = rotation_vector
		
		projectile.damage = damage
		
		if projectile is RigidBody3D:
			projectile.linear_velocity = forward_direction * projectile_speed
	
	# Reset shooting state
	can_shoot = false
	shoot_timer.start()









#scaled by both ptich and yaw 
func get_forward_direction_from_yaw_and_pitch(euler_angles: Vector3) -> Vector3:
	
	var pitch = euler_angles.x
	var yaw = euler_angles.y
	
	var forward_x = sin(yaw) * cos(pitch)
	var forward_y = -sin(pitch)
	var forward_z = cos(yaw) * cos(pitch)
	
	return Vector3(forward_x, forward_y, forward_z).normalized()
	
	#Yaw rotation = | cos(y)  0  sin(y)| |0|   |sin(y)|
			  #	    | 0       1  0     | |0| = |  0   |
				   #|-sin(y)  0  cos(y)| |1|   |cos(y)|


#only use for testin, scaled only by yaw(ry)
func get_forward_direction_yaw_only(euler_angles: Vector3) -> Vector3:
	var rx = euler_angles.x
	var ry = euler_angles.y
	
	#x,y,z components of forward direction vector
	#i.e forward_direction = Rx * (Ry * [0,0,1]), this is give you forward or the 3rd column vector after you done the matrix multiplication
	var forward_x = sin(ry)  # Only affected by yaw
	var forward_y = -sin(rx) * cos(ry)  # Affected by both  pitch and  yaw
	var forward_z  = cos(rx) * cos(ry)  #  ^
	
	#[0,0,-1] is forwar
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
func setup_debug():
	info_label = Label3D.new()
	info_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	info_label.font_size = 16
	info_label.position = Vector3(0, 2, 0)
	info_label.modulate = Color.WHITE
	rotation_area.add_child(info_label)
	
	var label_colors = {
		"target": Color.RED,
		"predicted": Color.BLUE,
		"pitch": Color.GREEN,
		"vision_boundary": Color.RED,      
		"detection_label": Color.BLUE   
	}
	
	for label_name in label_colors:
		var label = Label3D.new()
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.font_size = 16
		label.modulate = label_colors[label_name]
		debug_labels[label_name] = label
		parent_node.add_child(label)

func draw_angle_boundaries():
	if not debug_mode:
		return

	var start_pos = rotation_area.global_position
	
	var forward_dir = rotation_area.global_transform.basis.z
	forward_dir.y = 0  
	forward_dir = forward_dir.normalized()
	
	var line_length = detection_radius

	# Draw horizontal angle boundaries
	var left_angle = deg_to_rad(-max_lock_on_angle)
	var right_angle = deg_to_rad(max_lock_on_angle)

	var left_bound = forward_dir.rotated(Vector3.UP, left_angle)
	var right_bound = forward_dir.rotated(Vector3.UP, right_angle)

	DebugDraw3D.draw_line(
		start_pos,
		start_pos + left_bound * line_length,
		Color.RED
	)
	DebugDraw3D.draw_line(
		start_pos,
		start_pos + right_bound * line_length,
		Color.RED
	)

	# Draw arc segments between boundaries
	var segments = 20
	var prev_point = start_pos + left_bound * line_length
	
	for i in range(1, segments + 1):
		var t = float(i) / segments
		var angle_t = left_angle + (right_angle - left_angle) * t
		var current_vector = forward_dir.rotated(Vector3.UP, angle_t)
		var current_point = start_pos + current_vector * line_length
		
		DebugDraw3D.draw_line(prev_point,current_point,Color(1, 0, 0, 0.5) )
		prev_point = current_point

	if debug_labels.has("vision_boundary"):
		debug_labels["vision_boundary"].position = right_bound + Vector3(1,0.8,0)
		debug_labels["vision_boundary"].scale = Vector3(2,2,2)
		debug_labels["vision_boundary"].text = "Vision_Boundary" 


# Detection radius circle
func draw_detection_radius():
	if not debug_mode or not detection_shape:
		return
		
	var segments = 32
	var center = detection_area.global_position

	
	for i in range(segments + 1):
		var angle_from = i * TAU / segments
		var angle_to = (i + 1) * TAU / segments
		
		var from = center + Vector3(cos(angle_from) * detection_radius, 0, sin(angle_from) * detection_radius)
		var to = center + Vector3(cos(angle_to) * detection_radius, 0, sin(angle_to) * detection_radius)
		
		DebugDraw3D.draw_line(from, to, Color.BLUE)
		if debug_labels.has("detection_label"):
			debug_labels["detection_label"].position =  Vector3(0,3.5,0) 
			debug_labels["detection_label"].scale = Vector3(4,4,4)
			debug_labels["detection_label"].text = "Detection Radius: %.1f" % detection_radius



func update_debug_info(target_pos: Vector3):
	if not debug_mode or not current_target:
		return
		
	var start_pos = rotation_area.global_position
	var to_target = target_pos - start_pos
	
	
	
	# Calculate debug info
	var horizontal_dist = Vector2(to_target.x, to_target.z).length()
	var height_diff = to_target.y
	var total_dist = to_target.length()
	var current_pitch = rad_to_deg(mount_rotation_pitch.rotation.x)
	var target_pitch = rad_to_deg(-atan2(height_diff, horizontal_dist))
	
	# Update info label
	info_label.text = (
		"Distance: %.1f m\n" +
		"Height Diff: %.1f m\n" +
		"Current Pitch: %.1f°\n" +
		"Target Pitch: %.1f°\n" +
		"Intercept Time(time to target): %.2f s"
	) % [
		total_dist,
		height_diff,
		current_pitch,
		target_pitch,
		last_intercept_time
	]

	if target_mode == TargetMode.PREDICTED_AIM and current_target is CharacterBody3D:
		info_label.text += "\nTarget Speed: %.1f m/s" % current_target.velocity.length()
	











	
