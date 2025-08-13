extends Node

var level_container : Node2D
var player : PlayerControl
var instance
var scene
var player_position

@onready var finalscreen = preload("res://Scenes/final_screen.tscn") as PackedScene

func _ready()->void:
	global_variables.trash_can.connect(load_level)
	global_variables.change_scene.connect(final_de_momento)
	global_variables.reset.connect(reset)
	global_variables.active_camera_clear()
	player = get_tree().get_first_node_in_group("player")
	level_container = get_tree().get_first_node_in_group("level_container")
	scene = load("res://Scenes/boss_playtest.tscn") as PackedScene
	load_level()

func load_level()->void:
	for child in level_container.get_children():
		child.queue_free()
		await child.tree_exited
	instance = scene.instantiate()
	level_container.add_child(instance)
	
	player_position = get_tree().get_first_node_in_group("player_start_pos") as Node2D
	player.teleport_to_location(player_position.position.x, player_position.position.y)

func reset()->void:
	player_position = get_tree().get_first_node_in_group("player_start_pos") as Node2D
	player.teleport_to_location(player_position.position.x, player_position.position.y)
	player.reset()

func final_de_momento()->void:
	get_tree().change_scene_to_packed(finalscreen)
