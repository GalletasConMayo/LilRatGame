extends Node2D
@export var player: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_entered(area: Area2D, attack:String):
	# Verifica si el área que entró es una Hurtbox de enemigo
	if area.is_in_group("enemy"):
		var enemy = area.get_parent()  # Obtiene el nodo padre (el enemigo)
		enemy.take_damage(player.DAMAGE)      # Llama a su función de recibir daño
		match attack:
			"wip_up":
				player.velocity.y = player.FALL_GRAVITY
			"wip_down":
				player.velocity.y = player.JUMP_VELOCITY * 2 / 3
			"wip":
				player.move_x( 200 * player.LAST_DIRECTION * -1, 0.2)
