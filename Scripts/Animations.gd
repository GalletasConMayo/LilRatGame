extends Node2D


func _ready():
	global_variables.state_signal.connect(play_animations)

func _process(delta):
	if Input.is_action_just_pressed("asd"):
		$Sprites/Ribbon.visible = global_variables.ribbon
		$AnimationPlayer.play("idle")

func play_animations(current_state)->void:

	$AnimationPlayer.play(current_state)
