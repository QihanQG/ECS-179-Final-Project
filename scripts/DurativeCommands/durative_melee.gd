class_name DurativeMeleeCommand
extends DurativeAnimation

func execute(character:Character) -> Command.Status:
	#assuming maxim has a melee animation
	#both this and projectile will use a hit box
	return _manage_durative_animation_command(character, "melee")
