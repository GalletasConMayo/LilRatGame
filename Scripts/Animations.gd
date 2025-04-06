extends Node2D

func _ready():
	global_variables.state_signal.connect(play_animations)

func play_animations(current_state)->void:
<<<<<<< HEAD
	#if current_state == "cwall":
		#$AnimationPlayer.play("normal_hit_2")
	#else:
	$AnimationPlayer.play(current_state)
=======
	if current_state == "cwall":
		#$AnimationPlayer.play("normal_hit_2")
		$AnimationPlayer.play("wall")
	else:
		$AnimationPlayer.play(current_state)
>>>>>>> 9deac1bc914cf78ad10a00b4ef3a9e9324bc9a3a
