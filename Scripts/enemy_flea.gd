extends CharacterBody2D

const JUMP_HEIGHT 	:float = 100
const JUMP_TTRISE 	:float = 0.4		#tiempo altura maxima
const JUMP_TTFALL 	:float = 0.3
const JUMP_VELOCITY	:float =(-1) *  2 * JUMP_HEIGHT / JUMP_TTRISE
const RISE_GRAVITY	:float =(-1) * -2 * JUMP_HEIGHT / (JUMP_TTRISE * JUMP_TTRISE)
const FALL_GRAVITY 	:float =(-1) * -2 * JUMP_HEIGHT / (JUMP_TTFALL * JUMP_TTFALL)

const attack = "parameters/StateMachine/conditions/attack"
const move = "parameters/StateMachine/conditions/move"
const jump = "parameters/StateMachine/attack/conditions/jump"
const diag_jump = "parameters/StateMachine/attack/conditions/diag_jump"
const idle = "parameters/StateMachine/conditions/idle"

var SPEED = 100.0
@export var jumping:bool = false
@export var jumping_diag:bool = false
@export var stay:bool = false

var direction:int = 1

@onready var animations = $animations/AnimationPlayer
@onready var animation_tree = $animations/AnimationTree
@onready var state_machine = animation_tree["parameters/StateMachine/playback"]

func _ready():
	pass


func _physics_process(delta):
	
	Y_movement(delta)
	X_movement()
	move_and_slide()


func X_movement()->void:
	if stay or jumping:velocity.x = 0
	elif !stay or !jumping or jumping_diag:
		if $collisions/RayCastFront.is_colliding() or (!$collisions/RayCastDown.is_colliding() and (!jumping and !jumping_diag)):
			direction *= -1
			redirection()
			print("CAMBIOS")
		velocity.x = 100 * direction
	else:
		velocity.x = 0


func Y_movement(delta)->void:
	if jumping or jumping_diag:
		velocity.y += RISE_GRAVITY * delta
	else:
		velocity.y += FALL_GRAVITY * delta


func idle_out()->void:
	var path = randf()
	if path < 0.4:
		#SM_condition(attack)
		SM_condition(move)
	elif path >= 0.4 and path < 0.8:
		SM_condition(move)
	else:
		#SM_condition(idle)
		SM_condition(move)

func jump_handler()->void:
	velocity.y = JUMP_VELOCITY*0.8


func next_attack():
	var path = randf()
	if path > 0.8 or $collisions/RayCastJump.is_colliding():
		SM_condition(diag_jump)
	else:
		SM_condition(jump)


func SM_condition(condition:String)->void:
	animation_tree[condition] = true
	await get_tree().create_timer(0.5).timeout
	animation_tree[condition] = false


func redirection()->void:
	if direction < 0:
		$collisions.scale.x = -1
		$animations.scale.x = -1
	elif direction >= 0:
		$collisions.scale.x = 1
		$animations.scale.x = 1
