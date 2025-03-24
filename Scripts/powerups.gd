extends Area2D
var pickable_name : String

# Called when the node enters the scene tree for the first time.
func _ready():
	pickable_name = get_name().strip_edges().rstrip("0123456789") 
	$AnimatedSprite.play(pickable_name)


func _on_body_entered(body):
	if body is PlayerControl:
		match pickable_name:
			"dash":
				global_variables.dash = true
			"doublejump":
				global_variables.double_jump = true
			"walljump":
				global_variables.wall_jump = true
			"cheese":
				global_variables.cheeses += 1
			"cheese_piece":
				if global_variables.cheese_piece == 4:
					global_variables.cheese_piece = 0
					global_variables.cheeses += 1
				else:
					global_variables.cheese_piece += 1
		queue_free()
