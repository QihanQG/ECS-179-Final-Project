extends Control

@onready var main = $"../"

func _on_resume_pressed():
	main.toggle_pause_menu()

func _on_quit_pressed():
	get_tree().quit()
