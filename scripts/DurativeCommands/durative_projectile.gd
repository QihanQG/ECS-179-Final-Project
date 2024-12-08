#if maxim has an animation for a fireball
class_name DurativeProjectileCommand
extends DurativeAnimation

func execute(character:Character) -> Command.Status:
	#assuming maxim found a aninmation for the penguin shooting a projecitle
	character.command_callback("projectile")
	return _manage_durative_animation_command(character, "projectile")
