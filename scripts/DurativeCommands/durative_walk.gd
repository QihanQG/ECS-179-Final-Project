class_name WalkCommand
extends DurativeController

var speed: float = 5.0

func _init(player: AnimationPlayer, speed: float, duration: float, character: CharacterBody3D):
	super._init(player, duration, character)
	self.speed = speed

func setup_animation(anim):
	anim.loop = true

func execute():
	super.execute()
	if is_moving:
		adjust_animation_speed()

func adjust_animation_speed():
	if animation_player:
		var ideal_speed = 3.0
		var speed_scale = speed / ideal_speed
		animation_player.speed_scale = speed_scale
		print("Adjusted animation speed scale to:", speed_scale)

func on_animation_complete():
	character.velocity = Vector3.ZERO
