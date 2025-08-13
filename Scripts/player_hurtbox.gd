extends Node2D
class_name PlayerHurtbox

func _process(delta):
	hp_check()


func hp_check()->void:
	if global_variables.hitpoints <= 0:
		print("ratoncito ded")
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


func _on_hurtbox_area_entered(area):
	print(area.name)
	global_variables.hitpoints -= 1
	get_tree().paused = true
	await get_tree().create_timer(0.3).timeout
	get_tree().paused = false
	$"../timers/IFrames".start()
	flash_white()
	$hurtbox.set_deferred("monitoring",false)


func _on_i_frames_timer_timeout():
	$hurtbox.set_deferred("monitoring",true)
