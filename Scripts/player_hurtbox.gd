extends Node2D
@export var player: CharacterBody2D

func _ready():
	player = get_parent()
	#$rat.set_deferred("monitorable",false)


func _process(delta):
	pass

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


func take_damage(damage: int, direction:float):
	player.HP -= damage
	hp_check()
	global_variables.hp_change.emit(player.HP)
	player.can_control = false
	hit_stop_time(0.1)
	$"../timers/ControlAfterDamage".start()
	#screen shake
	IFrames()
	player.move_x(500 * direction, 0)
	player.velocity.y = -120
	flash_white()


func IFrames()->void:
	$"../timers/IFrames".start()
	$rat.set_deferred("monitorable",false)
	print(get_child(0).monitorable)


func hit_stop_time(seconds:float)->void:
	get_tree().paused = true
	await get_tree().create_timer(seconds).timeout
	get_tree().paused = false


func _on_i_frames_timeout() -> void:
	$rat.set_deferred("monitorable", true)
