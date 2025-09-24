extends Control

func _ready():
	global_variables.hp_change.connect(hp_change)
	global_variables.cheeses = 0
	global_variables.cheese_piece = 0
	global_variables.max_cheeses = 4

func _process(delta):
	check_hud_variables()

func hp_change()->void:
	print("xd")

func check_hud_variables()->void:
	for label in $HBoxContainer/GridContainer.get_children(): #recorre las etiquetas para cambiar los numeros
		match label.name:
			"hitpoins":
				pass
			"cheeses":
				label.text = str(global_variables.cheeses)
			"cheese_piece":
				label.text = str(global_variables.cheese_piece)
