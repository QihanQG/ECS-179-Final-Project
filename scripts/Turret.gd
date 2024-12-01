class_name Turret
extends StaticBody3D


@export var rotation_speed: float = 50.0
@export var barrel_length: float = 1.2
@export var projectile_speed: float = 120.0
@export var fire_rate: float = 0.4
#@export var rotation_duration: float = 5.0

@onready var turret_vision_mesh: MeshInstance3D = $TurretRotation/detect_visual  #the mesh of the turret vision cone or "vision"
@onready var turret_vision:CylinderMesh  #The  mesh properties(radius,height) of vision_cone 
@onready var detection_area: Area3D = $DetectionArea  #radius detection

@onready var spawn_point = $TurretRotation/projectile_spawn/projectile_spawn_marker

var is_rotating: bool = true
var can_shoot: bool = true
var shoot_timer: Timer
var rotate_timer: Timer

var  projectile_scene = preload("res://scenes/projectiles.tscn")

var potential_targets: Array = []
var current_target = null

var in_turret_vison: bool = false

#target normal
enum TargetMode {NORMAL, PREDICTED_AIM}
@export var target_mode: TargetMode = TargetMode.NORMAL



func _ready():
	#shoot timer
	shoot_timer = Timer.new()
	add_child(shoot_timer)
	shoot_timer.wait_time = fire_rate
	shoot_timer.one_shot = true
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	
	#rotational timer
	#rotate_timer = Timer.new()
	#add_child(rotate_timer)
	#rotate_timer.wait_time = rotation_duration
	#rotate_timer.one_shot = false
	#rotate_timer.timeout.connect(_on_rotation_timeout)
	#rotate_timer.start()
	
	turret_vision = turret_vision_mesh.mesh #set the turret_vision to all of vision_cone properties
	
	#debug_statements()


	
func _process(delta):
	if not potential_targets.is_empty():
		current_target  = find_closest_target()
		if current_target:
			aim_at_target(current_target.global_position)
			if can_shoot:
				shoot()


func print_node_hierarchy(node: Node, indent: int) -> void:
	var indent_str = "  ".repeat(indent)
	print(indent_str + node.name + " (" + node.get_class() + ")")
	
	# Print transform data for spatial nodes
	if node is Node3D:
		print(indent_str + "  - Global Position: " + str(node.global_position))
		print(indent_str + "  - Local Position: " + str(node.position))
		print(indent_str + "  - Global Rotation: " + str(node.global_rotation))
		print(indent_str + "  - Local Rotation: " + str(node.rotation))
		print(indent_str + "  - Scale: " + str(node.scale))
	
	# Recursively print children
	for child in node.get_children():
		print_node_hierarchy(child, indent + 1)	
	

func _on_detection_area_body_entered(body: Node3D) -> void:
	#print("Body entered: ", body.name)
	if body.is_in_group("enemies"):
		potential_targets.append(body)
		print(potential_targets)
		
		#_debug_statements_body_entered()
	#print(body.name)



#not used currently
func _is_in_vision_cone(target_position: Vector3) -> bool:
	# Use vision cone position instead of turret base
	var to_target = target_position - turret_vision_mesh.global_position
	
	# Get forward direction from transform
	var cone_forward = -$TurretRotation.global_transform.basis.z
	
	if to_target.length() > turret_vision.height:
		return false
		
	# Ignore Y component
	var flat_to_target = Vector3(to_target.x, 0, to_target.z).normalized()
	var flat_forward = Vector3(cone_forward.x, 0, cone_forward.z).normalized()
	
	# Clamp dot product
	var dot_product = clampf(flat_forward.dot(flat_to_target), -1.0, 1.0)
	var angle_differences = rad_to_deg(acos(dot_product))
	
	var cone_angle = rad_to_deg(atan2(turret_vision.bottom_radius, turret_vision.height))

	
	#print(angle_differences)
	return angle_differences <= cone_angle


#To-Do
func _on_turret_vision_body_entered(body: Node3D) -> void:
	in_turret_vison = true

func _on_turret_vision_body_exited(body: Node3D) -> void:
	in_turret_vison = false


	
func aim_at_target(target_position:Vector3):
	
	var to_target: Vector3
	
	match target_mode:
		TargetMode.NORMAL:
			to_target = target_position - $TurretRotation.global_position
		TargetMode.PREDICTED_AIM:
			var aim_position = aim_at_predicted_target(target_position)
			to_target = aim_position - $TurretRotation.global_position
		
	var to_target_normalized  = to_target.normalized()
	
	var current_direction = get_forward_direction($TurretRotation.rotation)
	
	#Use dot product to get the angle.
	var dot_product = current_direction.dot(to_target_normalized)
	var angle_diff = rad_to_deg(acos(dot_product))

	# angle_diff > 0 mean the turret barrel is not facing the enemies/objects
	if angle_diff > 0.1:  
	
		#We only use the Y component because we're only rotating Y axis(turning left and right).
		#Positive y = rotate counterclockwise around Y axis, Negative y = rotate clockwise around Y axis.
		var cross_product = current_direction.cross(to_target_normalized)
		var rotation_direction = 1 if cross_product.y > 0 else -1
		
		#Apply rotation
		var smoothing_factor: float = 5.0
		var rotation_amount = rotation_speed * get_process_delta_time()
		rotation_amount = lerp(0.0, rotation_amount, smoothing_factor * get_process_delta_time())
		$TurretRotation.rotate_y(rotation_direction * rotation_amount)


func aim_at_predicted_target(target_position: Vector3) -> Vector3:
	if not current_target or not (current_target is CharacterBody3D):
		return target_position
		
	var target_velocity = current_target.velocity
	
	#The time bullet needs to reach current target position
	#Time = Distance / Speed => distance = target's current position - turret position
	var distance = (target_position - global_position).length()
	var time_to_target = distance / projectile_speed
	
	
	#Distance = Velocity × Time = > New Position = Starting Position + Distance traveled
	#New Position = Starting Position + (Velocity × Time) = > predicted_position = current_position + (velocity * time)
	var predicted_position = target_position + (target_velocity * time_to_target)
	
	#For handling acceleration, i.e bulletdrop: P_predicted = P_current + (V × t) + (½ × a × t²)
	var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	predicted_position.y += 0.5 * gravity * time_to_target * time_to_target
	
	return predicted_position



func find_closest_target():
	var closest_target = null
	var closest_distance = INF
	
	#temporary arrau  for targets to remove
	var targets_to_remove = []
	for target in potential_targets:
		# Check if target is still valid
		if is_instance_valid(target) and target != null:
			var distance = (target.global_position - global_position).length()
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



func _on_rotation_timeout():
	if is_rotating:
		is_rotating = false
	else:
		is_rotating = true

func _on_shoot_timer_timeout():
	can_shoot = true



func shoot():
	var projectile = projectile_scene.instantiate()
	get_tree().root.add_child(projectile)

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
		
	


func debug_statements() -> void:

	print("vision cone top radius: ",turret_vision.top_radius)
	print("vision cone bottom radius: ", turret_vision.bottom_radius)
	print("vision cone height ", turret_vision.height)
	print("vision cone position ", turret_vision_mesh.global_position)
	print("vision cone rotation ", turret_vision_mesh.global_rotation)
	
	
		# Debug node hierarchy
	print("\n=== FULL NODE HIERARCHY ===")
	print_node_hierarchy(self, 0)
	
	print("\n=== DETAILED NODE PROPERTIES ===")
	# Debug turret rotation node
	print("\nTurret Rotation Node:")
	if has_node("TurretRotation"):
		var turret_rotation = $TurretRotation
		print("- Position:", turret_rotation.global_position)
		print("- Rotation:", turret_rotation.global_rotation)
		print("- Scale:", turret_rotation.scale)
	
	# Debug vision cone properties
	print("\nVision Cone Properties:")
	if turret_vision_mesh:
		print("- Mesh Position:", turret_vision_mesh.global_position)
		print("- Mesh Local Position:", turret_vision_mesh.position)
		print("- Mesh Global Rotation:", turret_vision_mesh.global_rotation)
		print("- Mesh Local Rotation:", turret_vision_mesh.rotation)
		print("- Mesh Scale:", turret_vision_mesh.scale)
	
	# Debug detection area
	print("\nDetection Area Properties:")
	if detection_area:
		print("- Position:", detection_area.global_position)
		print("- Rotation:", detection_area.global_rotation)
		print("- Scale:", detection_area.scale)
		if detection_area.get_child_count() > 0:
			for child in detection_area.get_children():
				if child is CollisionShape3D:
					print("- Collision Shape Type:", child.shape.get_class())
					# If it's a cylinder shape
					if child.shape is CylinderShape3D:
						print("  - Height:", child.shape.height)
						print("  - Radius:", child.shape.radius)
	
	# Debug spawn point
	print("\nProjectile Spawn Point:")
	if spawn_point:
		print("- Global Position:", spawn_point.global_position)
		print("- Local Position:", spawn_point.position)
		print("- Global Rotation:", spawn_point.global_rotation)
		print("- Local Rotation:", spawn_point.rotation)	
