extends Node2D

# Señal para notificar cuando el ataque termina
signal attack_finished

# Variables exportables 
@export var damage := 10
@export var cooldown := 0.5


@onready var hitbox := $"Attack-Hitbox"
@onready var animation_player := $"Attack-animation"

var is_attacking := false

# Función para iniciar el ataque
func execute_attack() -> void:
	if not is_attacking:
		is_attacking = true
		animation_player.play("BasicAttack")  # Nombre de la animación en el AnimationPlayer
		enable_hitbox(true)

# Habilita/deshabilita la hitbox
func enable_hitbox(active: bool) -> void:
	hitbox.monitoring = active  

# Conectado a la señal "animation_finished" del AnimationPlayer
func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "BasicAttack":
		enable_hitbox(false)
		is_attacking = false
		emit_signal("attack_finished")
