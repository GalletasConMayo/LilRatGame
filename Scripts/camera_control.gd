extends Node2D

enum FollowMode {
	NONE 			= 0, ## Default - No follow logic is applied.
	GLUED 			= 1, ## Sticks to its target.
	SIMPLE 			= 2, ## Follows its target with an optional offset.
	GROUP 			= 3, ## Follows multiple targets with option to dynamically reframe itself.
	PATH 			= 4, ## Follows a target while being positionally confined to a [Path2D] node.
	FRAMED 			= 5, ## Applies a dead zone on the frame and only follows its target when it tries to leave it.
}

func _ready()->void:
	global_variables.camera_search.connect(search_active_camera)

func _process(delta):
	pass

func search_active_camera()->void:
	var level_container = get_tree().get_first_node_in_group("level_container")
	var level_children = level_container.get_child(0).get_children()
	#aqui se obtiene la lista con todos los nodos del level
	for node in level_children: #se busca por el area
		if node.name == "cameras":
			var areas = node.get_children() #lista con las areas
			for active_area in areas:
				if active_area.name == global_variables.active_camera[0]:
					var phantomcamera = active_area.get_node_or_null("PhantomCamera2D")
					var player = get_tree().get_first_node_in_group("player")
					phantomcamera.follow_mode = FollowMode.GLUED
					phantomcamera.set_follow_target(player)
					phantomcamera.set_follow_damping(false)
					#phantomcamera.set_follow_offset(Vector2(1, 1))
