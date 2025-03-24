extends TileMap

func _on_area_2d_body_entered(body):
	$".".visible = false
	#añadir animacion

func _on_area_2d_body_exited(body):
	$".".visible = true
