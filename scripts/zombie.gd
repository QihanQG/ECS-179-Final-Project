extends CharacterBody3D

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
var attack_command: AttackCommand
var turn_right_command: TurnRightCommand
var turn_left_command: TurnLeftCommand
var idle_command: IdleCommand
var death_command: DeathCommand
var run_command: RunCommand

func _ready():
	#print("Script starting...")
	add_to_group("enemies")

	walk_command = WalkCommand.new(walk, walk_speed, 20, self)
	attack_command = AttackCommand.new(attack, 1.0, self)
	turn_right_command = TurnRightCommand.new(turn_right, 0.5, self)
	turn_left_command = TurnLeftCommand.new(turn_left, 0.5, self)
	idle_command = IdleCommand.new(idle, self)
	death_command = DeathCommand.new(death, 2.0, self)
	run_command = RunCommand.new(run, run_speed, 20, self)  
	

	add_child(walk_command)
	add_child(attack_command)
	add_child(turn_right_command)
	add_child(turn_left_command)
	add_child(idle_command)
	add_child(death_command)
	add_child(run_command)
	
	
	idle_command.execute()
	
	#TRY THE COMMANDS HERE, USE await to create a timer or create FSM to make sure the animations plays sequentially 
	
	start_walk()

func _physics_process(delta):
	var direction = transform.basis.z
	if walk_command.is_moving:
		velocity = direction * walk_speed
	elif run_command.is_moving:
		velocity = direction * run_speed * 2
	else:
		velocity = Vector3.ZERO
	move_and_slide()

func start_walk():
	stop_all()
	walk_command.execute()

func start_attack():
	stop_all()
	attack_command.execute()

func start_turn_right():
	stop_all()
	turn_right_command.execute()

func start_turn_left():
	stop_all()
	turn_left_command.execute()

func start_idle():
	stop_all()
	idle_command.execute()

func start_death():
	stop_all()
	death_command.execute()

func start_run():
	stop_all()
	run_command.execute()

func stop_all():
	walk_command.stop()
	run_command.stop()
	attack_command.stop()
	turn_right_command.stop()
	turn_left_command.stop()
	idle_command.stop()
	death_command.stop()
