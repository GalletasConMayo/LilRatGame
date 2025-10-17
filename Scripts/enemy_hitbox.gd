extends Node2D
#var player: PlayerControl

# Called when the node enters the scene tree for the first time.
func _ready():
	#player = get_tree().get_first_node_in_group("player")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_entered(area: Area2D):
	# Verifica si el área que entró es una Hurtbox de enemigo
	if area.is_in_group("player"):
		var player = area.get_parent() # Obtiene el nodo padre (el enemigo)
		var vector_direction = (player.global_position - global_position).normalized()
		player.take_damage(0, vector_direction.x)      # Llama a su función de recibir daño
