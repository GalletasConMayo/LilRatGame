extends Area2D

func _physics_process(delta):
	hp_check()


func hp_check()->void:
	if global_variables.hitpoints <= 0:
		print("ratoncito ded")
		set_physics_process(false)
		#ded animation play 
		await get_tree().create_timer(2).timeout
		queue_free()


func _on_hurtbox_area_entered(area):
	$Hurtbox.disabled = true
	$"../timers/IFramesTimer".start()
	flash_white()
	get_tree().paused = true
	await get_tree().create_timer(0.3).timeout
	get_tree().paused = false


func _on_i_frames_timer_timeout():
	$Hurtbox.disabled = false


func flash_white():
	var i = 0
	while i < 10:
		$"../animations/Sprites".material.set_shader_parameter("flash_modifier", 1.0)
		await get_tree().create_timer(0.3).timeout
		$"../animations/Sprites".material.set_shader_parameter("flash_modifier", 0)
		i+=1
