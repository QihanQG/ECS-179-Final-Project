# BaseAnimationCommand.gd
class_name DurativeController
extends Node

var animation_player: AnimationPlayer
var duration: float = 3.0
var timer: float = 0.0
var character: CharacterBody3D
var is_moving: bool = false

func _init(player: AnimationPlayer, duration: float, character: CharacterBody3D):
	self.animation_player = player
	self.duration = duration
	self.character = character

func execute():
	if animation_player:
		print("Playing animation for", duration, "seconds...")
		var animations = animation_player.get_animation_list()
		if animations.size() > 0:
			var anim_name = animations[0]
			var anim = animation_player.get_animation(anim_name)
			if anim:
				setup_animation(anim)
				animation_player.play(anim_name)
				timer = duration
				self.is_moving = true

func setup_animation(anim):
	anim.set_loop_mode(Animation.LOOP_NONE)  # non-looping, it will stop animations at the last frame

func _process(delta):
	if self.is_moving:
		if animation_player.is_playing():
			timer -= delta
			if timer <= 0:
				animation_player.stop()
				print("Animation has stopped after given duration.")
				on_animation_complete()
				self.is_moving = false
				set_process(false)

func on_animation_complete():
	pass

func stop():
	if animation_player and animation_player.is_playing():
		animation_player.stop()
		is_moving = false
		on_animation_complete()
