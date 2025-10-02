extends Control
var i = 0

func _ready():
	global_variables.hp_change.connect(hp_change)
	global_variables.first_hp_anim.connect(first_hp_anim)
	#global_variables.cheeses = 0
	#global_variables.cheese_piece = 0
	#global_variables.max_cheeses = 4

func first_hp_anim(max_hp)->void:
	while i < max_hp:
		$HBoxContainer/GridContainer/hitpoins.text = str(i)
		i += 1

func hp_change(new_hp)->void:
	$HBoxContainer/GridContainer/hitpoins.text = str(new_hp)
