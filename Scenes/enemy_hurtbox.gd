extends Node2D

func hp_check()->void:
	pass


func flash_white():
	$"../animations/Sprite2D".material.set_shader_parameter("flash_modifier", 1.0)
	await get_tree().create_timer(0.1).timeout
	$"../animations/Sprite2D".material.set_shader_parameter("flash_modifier", 0)
	await get_tree().create_timer(0.1).timeout
	

func _on_hurtbox_area_entered(area):
	print(area.name)
	global_variables.hitpoints -= 1
	hit_stop_time(0.3)
	flash_white()
	$hurtbox.set_deferred("monitoring",false)


func hit_stop_time(seconds:float)->void:
	get_tree().paused = true
	await get_tree().create_timer(seconds).timeout
	get_tree().paused = false


func _on_i_frames_timer_timeout():
	$hurtbox.set_deferred("monitoring",true)
