class_name EnemyAttack
extends Node

'''TODO AFTER MAP IS FINISHED, TEST DURATION AROUND MAP TO KNOW WHERE THE ENEMIES SHOULD WALK'''

@export var _enemy : EnemyPenguin
@export var _king_penguin: KingPenguin
func spawn_enemies():
	_king_penguin.started_loop = true
	battle_loop();
	
	func battle_loop():
		# TODO : ONCE MAP IS DONE ADD IN THE MOVEMENT LOOPS

func _physics_process(delta: float) -> void:
	#repeat boss actions until player or boss dies	
	battle_loop();
