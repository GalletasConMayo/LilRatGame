extends Node2D

func _ready():
	global_variables.state_signal.connect(play_animations)


func play_animations(current_state)->void:
	$AnimationPlayer.play(current_state)
