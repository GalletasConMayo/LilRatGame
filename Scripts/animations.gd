extends Node2D

const state = ["idle", "sleep", "walk", "run", "jump", "fall", 
"dash", "wall", "cwall", "normal_hit_1",  "normal_hit_2", "charge_hit"]

func _ready():
	global_variables.state_signal.connect(play_animations)


func play_animations(current_state)->void:
	$AnimationPlayer.play(state[current_state])
