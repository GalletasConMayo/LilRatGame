extends Area2D

@export var damage := 10

func _ready() -> void:
	# Conexión CORRECTA en Godot 4.2.2
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hurtbox"):
		area.get_parent().take_damage(damage)  # Llama a una función en el enemigo
