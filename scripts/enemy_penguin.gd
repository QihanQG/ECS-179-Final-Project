class_name EnemyPenguin
extends Character 

var health:int = 100
var target : Character
var cmd_list : Array[Command]

var _death:bool = false

@onready var audio_player:AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready() -> void:
	#NOTE: HERE CHANGE TARGET TO WALLS
	# target = 
	movement_speed = 400
	$Sprite3D.visible = false


func _process(_delta):
	if _death:
		if !animation_player.is_playing():
			sprite.visible = false
		return
		
	if len(cmd_list)>0:
		var command_status:Command.Status = cmd_list.front().execute(self)
		#if command_status == Command.Status.ACTIVE:
		if Command.Status.DONE == command_status:
			cmd_list.pop_front()
	else:
		animation_player.play("idle")

# THIS IS FOR MY AUDIO PART IN WEEK3 IMPLEMENTATION
func take_damage(damage:int):
	health -= damage
	
	audio_player.stop()
	#NOTE:  WEEK 3 TO DO GOAL: IMPLEMENT AUDIO
	#audio_player["parameters/switch_to_clip"] = " "
	audio_player.play()

	if 0 >= health:
		_death = true
		velocity = Vector2.ZERO
		audio_player.stop()
		#todo death sounds
		#audio_player["parameters/switch_to_clip"] = ""
		audio_player.play()
		# todo death animation w maxim
		animation_player.play_(" ")


func command_callback(command_name:String) -> void:
	if "melee" == command_name:
		audio_player.stop()
		audio_player["parameters/switch_to_clip"] = " "
		audio_player.play()
	if "move_right" == command_name:
		audio_player.stop()
		audio_player["parameters/switch_to_clip"] = " "
		audio_player.play()
	if "move_left" == command_name:
		audio_player.stop()
		audio_player["parameters/switch_to_clip"] = " "
		audio_player.play()
	if "projectile" == command_name:
		audio_player.stop()
		audio_player["parameters/switch_to_clip"] = " "
		audio_player.play()
	
