extends Control

@onready var GAME_MANAGER = preload("res://Scenes/game.tscn") as PackedScene

var menu_parent_path: NodePath
var menu_parent : Node

var cursor_index : int
var focus : bool = false

func _ready():
	$niveles.visible = false
	$controles/HBoxContainer/sprite/AnimatedSprite2D.play("default")
	
func _process(delta):
	if Input.is_action_just_released("ui_accept"):
		$controles.visible = false
		$niveles.visible = true
		if !focus:
			focus = true
			$niveles/GridContainer/Button.grab_focus()

func _on_button_button_up():
	get_tree().change_scene_to_packed(GAME_MANAGER)


func _on_button_2_button_up():
	get_tree().change_scene_to_packed(GAME_MANAGER)


func _on_button_3_button_down():
	get_tree().change_scene_to_packed(GAME_MANAGER)


func _on_button_4_button_down():
	get_tree().change_scene_to_packed(GAME_MANAGER)
