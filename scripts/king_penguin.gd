class_name KingPenguin
extends Character 

@export var wall_health:int = 100

var _damaged:bool = false
var _dead:bool = false
var cmd_list : Array[Command]

@onready var animation_tree:AnimationTree = $AnimationTree


func _ready():
	animation_tree.active = true
	bind_player_input_commands()
	

func _physics_process(delta: float):
	if _dead:
		return
	
	#if Input.is_action_just_pressed("summon_healer"): -> ask groupmates how they want to trigger summoning penguins
	#if Input.is_action_just_pressed("summon_researcher"):
	#if Input.is_action_just_pressed("summon_builder"):
	#if Input.is_action_just_pressed("summon_engineer"):
	
	idle.execute(self)
	super(delta)
	


	if len(cmd_list)>0:
		var command_status:Command.Status = cmd_list.front().execute(self)
		#if command_status == Command.Status.ACTIVE:
		if Command.Status.DONE == command_status:
			cmd_list.pop_front()
		else:
			animation_player.play("idle")

# need to test, when the wall take damage, our kind penguin should take damage
func take_damage(wall_damage:int) -> void:
	wall_health -= wall_damage
	_damaged = true
	if 0 >= wall_health:
		_play($Audio/defeat)
		_dead = true
		animation_tree.active = false
		animation_player.play("death")
	else:
		_play($Audio/hurt)


#Logic to support the state machine in the AnimationTree
#func _manage_animation_tree_state() -> void:
	#TODO: LATE, TO DO BY MONDAY, NEED TO WRITE LOGIC TO SUPPORT MAXIMS ANIMATION TREE


func bind_player_input_commands():
	idle = Command.new()


func unbind_player_input_commands():
	idle = Command.new()


func command_callback(cmd_name:String) -> void:
	if "summon" == cmd_name:
		_play($Audio/attack)

	if "death" == cmd_name:
		_play($Audio/death)

func _play(player:AudioStreamPlayer2D) -> void:
	if !player.playing:
		player.play()
