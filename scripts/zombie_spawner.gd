class_name ZombieSpawner
extends Node3D

"Implementation: Penelope's part -Enemy Behavior
 Code to spawn the enemy zombies in. Plan is to have at least 1 or 2 waves in 
 before the showcase, zombies spawn, they all stay at a fixed speed, but the
difficulty will lie in the numbers, maybe will edit speed if I make an algorithm
to adjust the walking path script times as speed multiplies"

@export var _zombie : PackedScene = load("res://scenes/zombie.tscn")
@export var _zombie_spawn_point : Marker3D 
@export var _zombie_wave_count : int = 2
@export var _total_zombie_in_wave : int = 6
@export var _spawn_interval: float = 2.0
@export var _wave_interval: float = 140.0

var _spawn_interval_timer: Timer 
var _current_zombie_wave: int = 0
var _current_zombie_count : int = 0

var _wave_interval_timer:Timer



func _ready():
	_spawn_interval_timer = Timer.new()
	_spawn_interval_timer.wait_time = _spawn_interval
	_spawn_interval_timer.one_shot = false
	add_child(_spawn_interval_timer)
	_spawn_interval_timer.timeout.connect(spawn_zombie)
	_spawn_interval_timer.start()
	"_wave_interval_timer = Timer.new()
	_wave_interval_timer.wait_time = _wave_interval
	_wave_interval_timer.one_shot = true
	add_child(_wave_interval_timer)
	_wave_interval_timer.timeout.connect(spawn_wave)"
	
	spawn_zombie()
	
"func spawn_wave():
	if _total_zombie_in_wave == 0 :
		spawn_zombie()
		
		_current_zombie_count += 1
	else:
		_wave_interval_timer.stop()"

		
func spawn_zombie():
	if _current_zombie_count < _total_zombie_in_wave:
		if _zombie and _zombie_spawn_point:
			var _zombie_instance = _zombie.instantiate()
			_zombie_instance.add_to_group("enemies")
			_zombie_instance.visible = true
			_zombie_instance.global_transform.origin = _zombie_spawn_point.global_transform.origin
			print(_zombie_instance.global_transform.origin)
			add_child(_zombie_instance)
			_current_zombie_count += 1
	else:
		_spawn_interval_timer.stop()
