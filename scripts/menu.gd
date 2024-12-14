extends VBoxContainer

const WORLD = preload("res://scenes/World.tscn")

func _on_new_game_button_pressed() -> void:
	$NewGameButton/AudioStreamPlayer3D
	get_tree().change_scene_to_packed(WORLD)


func _on_quit_button_pressed() -> void:
	$QuitButton/AudioStreamPlayer3D
	get_tree().quit()
