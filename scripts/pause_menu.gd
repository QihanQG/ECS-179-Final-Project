# pause_menu.gd
extends Control

@onready var main = $"../"
@onready var game_over_label = $GameOverLabel

func _ready():
	hide()
	if game_over_label:
		game_over_label.hide()

func _on_resume_button_pressed():
	main.toggle_pause_menu()

func _on_quit_button_pressed():
	get_tree().quit()

func show_game_over():
	show()
	get_tree().paused = true
	if game_over_label:
		game_over_label.show()
	$ResumeButton.hide()
