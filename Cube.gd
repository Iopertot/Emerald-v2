extends MeshInstance3D

@export var audio_stream_player:AudioStreamPlayer
var tilt_vector = Vector3(3, -3, 0)

func _process(delta):
	rotation_degrees += tilt_vector * delta * 8
