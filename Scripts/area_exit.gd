extends Node2D

func _on_area_2d_body_entered(body)->void:
	if body is PlayerControl:
		global_variables.trash_can.emit()


func _on_area_2d_2_body_entered(body):
	if body is PlayerControl:
		global_variables.change_scene.emit()
