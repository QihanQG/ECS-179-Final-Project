class_name IdleCommand
extends DurativeController

func _init(player: AnimationPlayer, character: CharacterBody3D):
	super._init(player, 0.0, character)

func setup_animation(anim):
	anim.set_loop_mode(Animation.LOOP_LINEAR)
