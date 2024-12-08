class_name DurativeRotationCommand
extends DurativeAnimation


var _rotation_speed :float = PI # 180 degree turn
var _theta:float
#this will chage according to map later
var _turn_duration: int
var _direction: Vector3 #get the character location
var _delta:float = 0.0


func _init(duration:int, direction:Vector3):
	_turn_duration = duration
	_direction = direction

func set_delta(delta:float):
	_delta = delta


func execute(character:Character) -> Command.Status:
	# just keep it in the idle animation
	_theta = wrapf(atan2(_direction.x, _direction.z) - character.rotate_y(), -PI, PI)
	var rotation_increment = clamp(_rotation_speed * _delta, 0 , abs(_theta) * sign(_theta))
	character.rotate_y(rotation_increment)

	#stop animation after turn timer endeds
	var track_time 
	track_time += _delta
	if track_time >= _turn_duration:
		return Status.DONE
	
	return _manage_durative_animation_command(character, "idle", _turn_duration)
	
