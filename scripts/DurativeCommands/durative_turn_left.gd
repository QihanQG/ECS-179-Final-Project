class_name TurnLeftCommand
extends DurativeController

var animation_done = false
var ani_timer : Timer
signal completed 

func _init(player: AnimationPlayer, duration: float, character: CharacterBody3D):
	super._init(player, duration, character)

func setup_animation(anim):
	anim.set_loop_mode(Animation.LOOP_NONE)

func execute():
	super.execute()
	animation_done = false
	ani_timer = Timer.new()
	add_child(ani_timer)
	ani_timer.start(duration)
	ani_timer.timeout.connect(on_animation_complete)

func on_animation_complete():
	animation_done = true
	if ani_timer:
		ani_timer.queue_free()
	emit_signal("completed")
