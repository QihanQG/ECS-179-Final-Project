class_name ZombieHitBox
extends Area3D


@export var damage:int = 10

func _init() -> void:
	collision_layer = 0
	collision_mask = 8
	area_entered.connect(_on_area_entered)


func _on_area_entered(hurtbox:ZombieHurtBox) -> void:
	if hurtbox.get_owner().has_method("take_damage"):
		hurtbox.owner.take_damage(damage)
