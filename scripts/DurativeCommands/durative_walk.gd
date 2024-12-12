class_name WalkCommand
extends DurativeController

var speed: float = 5.0
var animation_done = false
var ani_timer : Timer
signal completed 

func _init(player: AnimationPlayer, speed: float, duration: float, character: CharacterBody3D):
	super._init(player, duration, character)
	self.speed = speed

func setup_animation(anim):
	anim.loop = true

func execute():
	super.execute()
	animation_done = false
	if not ani_timer:
		ani_timer = Timer.new()
		add_child(ani_timer)
		ani_timer.start(duration)
		ani_timer.timeout.connect(on_animation_complete)
	if is_moving:
		adjust_animation_speed()

func adjust_animation_speed():
	if animation_player:
		var ideal_speed = 3.0
		var speed_scale = speed / ideal_speed
		animation_player.speed_scale = speed_scale
		print("Adjusted animation speed scale to:", speed_scale)

func on_animation_complete():
	animation_done = true
	character.velocity = Vector3.ZERO
	if ani_timer:
		ani_timer.queue_free()
		ani_timer = null
	emit_signal("completed")
