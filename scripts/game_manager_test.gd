extends Node

func _ready():
	# Get reference to GameManager
	var game_manager = get_parent()
	
	# Connect to signals for testing
	game_manager.connect("resource_changed", _on_resources_changed)
	game_manager.connect("wave_started", _on_wave_started)
	# Will uncomment out once implemented
	#game_manager.connect("building_damaged", _on_building_damaged)
	#game_manager.connect("game_over", _on_game_over)
	#game_manager.connect("penguins_assigned", _on_penguins_assigned)
	#game_manager.connect("production_speed_changed", _on_production_speed_changed)
	
	# Setup test timer
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2.0
	timer.one_shot = false
	timer.connect("timeout", run_test_sequence)
	timer.start()

var test_phase = 0

func run_test_sequence():
	var game_manager = get_parent()
	
	match test_phase:
		0:  # Initial state test
			print("\n=== Testing Initial State ===")
			print("Available penguins:", game_manager.get_available_penguins())
			print("Current resources:", game_manager.get_resources())
			test_phase += 1
			
		1:  # Test penguin assignment to research
			print("\n=== Testing Research Assignment ===")
			game_manager.assign_penguins("research", 2)
			test_phase += 1
			
		2:  # Test penguin assignment to factory
			print("\n=== Testing Factory Assignment ===")
			game_manager.assign_penguins("factory", 2)
			test_phase += 1
			
		3:  # Test resource management
			print("\n=== Testing Resource Management ===")
			game_manager.modify_resources(1000)  # Try adding resources
			test_phase += 1
			
		4:  # Test turret placement
			print("\n=== Testing Turret Placement ===")
			var turret_cost = 100.0
			if game_manager.try_place_turret(turret_cost):
				print("Successfully placed turret! Cost: ", turret_cost)
			test_phase += 1
			
		5:  # Test wave management
			print("\n=== Testing Wave Management ===")
			if game_manager.is_game_active():
				game_manager.start_wave()
			test_phase = 0  # Reset for next round of tests

# Signal handlers
func _on_resources_changed(new_amount: float):
	print("Resources changed to:", new_amount)

func _on_wave_started(wave_number: int):
	print("Wave", wave_number, "started!")

func _on_building_damaged(building_name: String, current_health: float):
	print(building_name, "damaged! Health:", current_health)

func _on_game_over(victory: bool):
	print("Game Over! Victory:", victory)

func _on_penguins_assigned(location: String, count: int):
	print("Penguins assigned - Location:", location, "Count:", count)

func _on_production_speed_changed(new_speed: float):
	print("Production speed changed to:", new_speed)
