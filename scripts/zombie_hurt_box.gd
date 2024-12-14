class_name ZombieHurtBox
extends Area3D

#just put a huge health number since its supposed to take out the castle as soon as it gets there
var damage:int = 1000

func _init() -> void:
	collision_layer = 8
	collision_mask = 0
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(hitbox:ZombieHitBox) -> void:
	if owner.has_method("take_damage"):
		owner.take_damage(damage)
