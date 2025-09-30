extends Node2D
@export var player: CharacterBody2D

signal hp_changed(HUD_HP: int)

func _ready():
	player = get_parent()

func _process(delta):
	hp_check()

func hp_check()->void:
	if player.HP <= 0:
		#ded animation play 
		#$"..".set_physics_process(false)
		$"..".can_control = false
		await get_tree().create_timer(2).timeout
		$"../animations".visible = false
		#$"..".queue_free()


func flash_white():
	var i = 0
	while i< 10:
		$"../animations/Sprites".material.set_shader_parameter("flash_modifier", 1.0)
		await get_tree().create_timer(0.1).timeout
		$"../animations/Sprites".material.set_shader_parameter("flash_modifier", 0)
		await get_tree().create_timer(0.1).timeout
		i+=1


func take_damage(damage: int):
	player.HP -= damage
	emit_signal("hp_changed", player.HP)
	player.player_move_to(player.direction, 0)
	hit_stop_time(0.3)
	$"../timers/IFrames".start()
	flash_white()


func hit_stop_time(seconds:float)->void:
	get_tree().paused = true
	await get_tree().create_timer(seconds).timeout
	get_tree().paused = false
