extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_current(false)
 # Replace with function body.

@onready var enemy: CharacterBody3D = $".."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
