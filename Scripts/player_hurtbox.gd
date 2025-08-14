extends Node2D
class_name PlayerHurtbox

func _process(delta):
	hp_check()


func hp_check()->void:
	if global_variables.hitpoints <= 0:
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
	hit_stop_time(0.3)
	$"../timers/IFrames".start()
	flash_white()
	$hurtbox.set_deferred("monitoring",false)


func hit_stop_time(seconds:float)->void:
	get_tree().paused = true
	await get_tree().create_timer(seconds).timeout
	get_tree().paused = false

func _on_i_frames_timer_timeout():
	$hurtbox.set_deferred("monitoring",true)
