extends Node

var double_jump : bool = false
var wall_jump : bool = false
var dash : bool = false

var player_camera : bool = true
var follow_player_camera : bool = false
var weapon : bool = false
var ribbon : bool = false

var active_camera: Array[String] = []
var exited_camera: String

var cheeses: int
var cheese_piece: int
var max_cheeses: int
var hitpoints : int
var max_hitpoints : int

signal camera_search()
signal trash_can()
signal reset()
signal debug()
signal change_scene()
signal state_signal(String)

func _ready():
	debug.connect(debug_variables)

func debug_variables()->void:
	double_jump = true
	wall_jump  = true
	dash = true
	
func active_camera_clear()->void:
	for element in active_camera:
		active_camera.erase(element)
