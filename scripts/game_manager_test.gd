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
	
	# Add a timer to run tests
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2.0
	timer.one_shot = false
	timer.connect("timeout", run_test_sequence)
	timer.start()


func run_test_sequence():
	var game_manager = get_parent()
	
	# Test resource management with turret placement
	print("Testing turret placement...")
	var turret_cost = 100.0
	if game_manager.try_place_turret(turret_cost):
		print("Successfully placed turret! Cost: ", turret_cost)
	else:
		print("Cannot afford turret!")
	
	# Test wave management
	if game_manager.is_game_active():
		game_manager.start_wave()

# Signal handling for testing
func _on_resources_changed(new_amount: float):
	print("Resources changed to:", new_amount)

func _on_wave_started(wave_number: int):
	print("Wave", wave_number, "started!")

func _on_building_damaged(building_name: String, current_health: float):
	print(building_name, "damaged! Health:", current_health)

func _on_game_over(victory: bool):
	print("Game Over! Victory:", victory)
