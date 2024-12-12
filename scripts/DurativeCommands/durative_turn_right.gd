class_name TurnRightCommand
extends DurativeController

func _init(player: AnimationPlayer, duration: float, character: CharacterBody3D):
	super._init(player, duration, character)

func setup_animation(anim):
	anim.set_loop_mode(Animation.LOOP_NONE)
