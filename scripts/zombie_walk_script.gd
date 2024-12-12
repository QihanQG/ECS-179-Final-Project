class_name ZombieWalkScript
extends CharacterBody3D

'Implementation: Penelope - Enemy movement,  Qihan - Animation integration
This is the durative command list for the zombies to walk down
a fixed path, once they reach the end of their path, they should start to
attack the base/villager penguin ' 

@export var walk: AnimationPlayer
@export var attack: AnimationPlayer
@export var turn_right: AnimationPlayer
@export var turn_left: AnimationPlayer
@export var idle: AnimationPlayer
@export var death: AnimationPlayer
@export var run: AnimationPlayer
@export var walk_speed: float = 5.0
@export var run_speed: float = 10.0 

# Store all command instances
var walk_command: WalkCommand
var walk_long_command : WalkLongCommand
var walk_short_command : WalkShortCommand
var attack_command: AttackCommand
var turn_right_command: TurnRightCommand
var turn_left_command: TurnLeftCommand
var idle_command: IdleCommand
var death_command: DeathCommand
var run_command: RunCommand

func _ready():
	
	add_to_group("enemies")
	

	walk_command = WalkCommand.new(walk, walk_speed, 6, self)
	walk_long_command = WalkLongCommand.new(walk, walk_speed, 15, self)
	walk_short_command = WalkShortCommand.new(walk, walk_speed, 4, self)
	attack_command = AttackCommand.new(attack, 1.0, self)
	turn_right_command = TurnRightCommand.new(turn_right, 0.5, self)
	turn_left_command = TurnLeftCommand.new(turn_left, 0.25, self)
	idle_command = IdleCommand.new(idle, self)
	death_command = DeathCommand.new(death, 2.5, self)
	run_command = RunCommand.new(run, run_speed, 2.5, self)  
	

	add_child(walk_command)
	add_child(walk_long_command)
	add_child(walk_short_command)
	add_child(attack_command)
	add_child(turn_right_command)
	add_child(turn_left_command)
	add_child(idle_command)
	add_child(death_command)
	add_child(run_command)
	
	await start_short_walk()
	await start_turn_right()
	await start_short_walk()
	await start_turn_left()
	await start_walk()
	await start_turn_right()
	await start_short_walk()
	await start_turn_right()
	await start_long_walk()
	await start_turn_left()
	await start_short_walk()
	await start_turn_left()
	await start_long_walk()
	await start_turn_right()
	await start_short_walk()
	await start_turn_right()
	await start_walk()
	await start_turn_left()
	await start_turn_right()
	await start_run()
	await start_turn_left()
	await start_short_walk()
	

func _physics_process(_delta):
	#print(self.velocity)
	var direction = global_transform.basis.z
	velocity = Vector3.ZERO  # Reset velocity each frame
	if walk_command.is_moving:
		velocity = direction * walk_speed
	elif walk_long_command.is_moving :
		velocity = direction * walk_speed
	elif walk_short_command.is_moving :
		velocity = direction * walk_speed
	elif run_command.is_moving:
		velocity = direction * run_speed * 2
	else:
		velocity = Vector3.ZERO
	move_and_slide()

func start_walk():
	stop_all()
	walk_command.execute()
	await walk_command.completed

func start_long_walk():
	stop_all()
	walk_long_command.execute()
	await walk_long_command.completed
	
func start_short_walk():
	stop_all()
	walk_short_command.execute()
	await walk_short_command.completed

func start_attack():
	stop_all()
	attack_command.execute()
	await attack_command.completed

func start_turn_right():
	stop_all()
	turn_right_command.execute()
	rotation.y += deg_to_rad(90)  
	await turn_right_command.completed

func start_turn_left():
	stop_all()
	turn_left_command.execute()
	rotation.y -= deg_to_rad(90)
	await  turn_left_command.completed

func start_idle():
	stop_all()
	idle_command.execute()
	await idle_command.completed

func start_death():
	stop_all()
	death_command.execute()
	await death_command.completed

func start_run():
	stop_all()
	run_command.execute()
	await run_command.completed

func stop_all():
	walk_command.stop()
	run_command.stop()
	attack_command.stop()
	turn_right_command.stop()
	turn_left_command.stop()
	idle_command.stop()
	death_command.stop()
