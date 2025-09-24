extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	#area_entered.connect(_on_area_entered)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_entered(area: Area2D):
	# Verifica si el área que entró es una Hurtbox de enemigo
	if area.is_in_group("enemy_hitbox"):
		var enemy = area.get_parent()  # Obtiene el nodo padre (el enemigo)
		enemy.take_damage()      # Llama a su función de recibir daño
