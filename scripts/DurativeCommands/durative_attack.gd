class_name AttackCommand
extends DurativeController

func _init(player: AnimationPlayer, duration: float, character: CharacterBody3D):
	super._init(player, duration, character)

func setup_animation(anim):
	anim.loop = true
