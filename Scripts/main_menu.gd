extends Control

@onready var button_1 = $MarginContainer/HBoxContainer/VBoxContainer/Button1
@onready var button_2 = $MarginContainer/HBoxContainer/VBoxContainer/Button2
@onready var LEVEL_SELECTOR = preload("res://Scenes/level_selector.tscn") as PackedScene
# Called when the node enters the scene tree for the first time.
func _ready():
	$MarginContainer/HBoxContainer/VBoxContainer/Button1.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_1_button_up():
	get_tree().change_scene_to_packed(LEVEL_SELECTOR)
	

func _on_button_2_button_up():
	get_tree().quit()

