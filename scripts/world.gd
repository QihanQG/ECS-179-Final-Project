extends Node3D

@onready var pause_menu: Control = $PauseMenu
var paused = false

# Hide the pause menu when the game starts
func _ready():
	pause_menu.hide()  # Ensure the pause menu is not visible at the start

func _process(delta):
	if Input.is_action_just_pressed("pause"):  # Ensure "pause" is defined in Input Map
		toggle_pause_menu()

func toggle_pause_menu():
	paused = !paused  # Toggle the pause state

	if paused:
		pause_menu.show()
		Engine.time_scale = 0  # Stop the game logic
	else:
		pause_menu.hide()
		Engine.time_scale = 1  # Resume the game logic



# Ready button 

@onready var zombie_spawner: ZombieSpawner = $ZombieSpawner  # Replace $ZombieSpawner with the correct node path


func _on_button_pressed():
	$UI/Control/ReadyButton.hide()
	zombie_spawner.start_spawning()
