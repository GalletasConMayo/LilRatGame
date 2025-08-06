extends Control

func _ready():
	global_variables.cheeses = 0
	global_variables.cheese_piece = 0
	global_variables.max_cheeses = 4
	global_variables.hitpoints = 5
	global_variables.max_hitpoints = 5

func _process(delta):
	check_hud_variables()

func check_hud_variables()->void:
	for label in $HBoxContainer/GridContainer.get_children(): #recorre las etiquetas para cambiar los numeros
		match label.name:
			"hitpoins":
				label.text = str(global_variables.hitpoints)
			"cheeses":
				label.text = str(global_variables.cheeses)
			"cheese_piece":
				label.text = str(global_variables.cheese_piece)
