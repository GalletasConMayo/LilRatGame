extends Node2D
@export var player: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_entered(area: Area2D):
	print("entre")
	# Verifica si el área que entró es una Hurtbox de enemigo
	if area.is_in_group("player"):
		print("grupo player998890989098909890")
		var enemy = area.get_parent()  # Obtiene el nodo padre (el enemigo)
		enemy.take_damage(player.DAMAGE)      # Llama a su función de recibir daño


func _on_jump_area_entered(area: Area2D) -> void:
	pass # Replace with function body.


func _on_jump_entered(area: Area2D) -> void:
	pass # Replace with function body.
