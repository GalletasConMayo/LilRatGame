extends Node2D
# Called when the node enters the scene tree for the first time.
func _ready():

	for camera in get_children():
		camera_limit(camera)
		camera.body_entered.connect(_on_camera_body_entered.bind(camera.name))
		camera.body_exited.connect(_on_camera_body_exited.bind(camera.name))


#Esta funcion es para obtener los parametros necesarios para limitar la camara a la cual quiero cambiar
func area_limit(area: Area2D)-> Dictionary:
	var collision_shape = area.get_node_or_null("CollisionShape2D")  # Buscar el nodo hijo

	var shape = collision_shape.shape.size / 2
	var top_limit = collision_shape.global_position.y - shape.y
	var bottom_limit = collision_shape.global_position.y + shape.y
	var left_limit = collision_shape.global_position.x - shape.x
	var right_limit = collision_shape.global_position.x + shape.x
	return {"shape":collision_shape.shape.size, "top":top_limit, "bottom":bottom_limit, "left":left_limit, "right":right_limit}

 
func camera_limit(area: Area2D)->void:
	var limits = area_limit(area)
	var phantomcamera = area.get_node_or_null("PhantomCamera2D")
	phantomcamera.set_limit_top(limits.top)
	phantomcamera.set_limit_bottom(limits.bottom)
	phantomcamera.set_limit_left(limits.left)
	phantomcamera.set_limit_right(limits.right)


func process_camera_priority(entered: bool)->void:
	var cameras_children = get_node(".").get_children() #esto recorre todos las camara_x
	for camera_area in cameras_children:
		if entered:
			for camara_string in global_variables.active_camera:
				if camara_string == camera_area.name:
					var phantomcamera = camera_area.get_node_or_null("PhantomCamera2D")
					phantomcamera.set_priority(10 - global_variables.active_camera.find(camara_string))
					global_variables.camera_search.emit()
		else:
			if global_variables.exited_camera == camera_area.name:
				var phantomcamera = camera_area.get_node_or_null("PhantomCamera2D")
				phantomcamera.set_priority(0)


#######################################################
#Auto limit/follow/priority/weas of all cameras

func area_enter(camara_string: String, body)->void:
	if body is PlayerControl:
		global_variables.active_camera.insert(0,camara_string)
		process_camera_priority(true)

func area_exit(camara_string: String, body)->void:
	if body is PlayerControl:
		global_variables.exited_camera = camara_string
		global_variables.active_camera.erase(global_variables.exited_camera)
		process_camera_priority(false)

func _on_camera_body_entered(body, camera_name):
	area_enter(camera_name, body)

func _on_camera_body_exited(body, camera_name):
	area_exit(camera_name, body)

#######################################################
#Manual cameras

func _on_initial_camera_body_exited(body):
	if body is PlayerControl:
		$initial_camera.queue_free()
