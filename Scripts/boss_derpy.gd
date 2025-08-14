extends CharacterBody2D
class_name Enemy

var player: PlayerControl
const  jump_attack = "parameters/esteimaxin/conditions/jump"
const dash_attack = "parameters/esteimaxin/conditions/dash"
const attacks = [jump_attack,dash_attack]
const preparation = "parameters/esteimaxin/conditions/prep"
const start = "parameters/esteimaxin/conditions/start"

var HP:int

var transition_count:int= 0
var flea_count:int = 0
var direction:int = 0

var secondjump:bool = false

@export var jumping:bool = false

@onready var animations = $animations/AnimationPlayer
@onready var animation_tree = $animations/AnimationTree
@onready var state_machine = animation_tree["parameters/esteimaxin/playback"]

const FALL_SPEED := 400
const INRANGE := 100

const JUMP_HEIGHT 	:float = 80
const JUMP_TTRISE 	:float = 0.2
const JUMP_TTFALL 	:float = 0.2
const JUMP_VELOCITY	:float =(-1) *  2 * JUMP_HEIGHT / JUMP_TTRISE
const RISE_GRAVITY	:float =(-1) * -2 * JUMP_HEIGHT / (JUMP_TTRISE * JUMP_TTRISE)
const FALL_GRAVITY 	:float =(-1) * -2 * JUMP_HEIGHT / (JUMP_TTFALL * JUMP_TTFALL)


func _ready():
	player = get_tree().get_first_node_in_group("player")
	await get_tree().create_timer(2).timeout
	global_variables.reset.connect(reset)
	animation_tree.set(start, true)


func _physics_process(delta: float):
	gravity(delta)
	move_and_slide()
	$hurtbox.hp_check()
	#print(animation_tree.get("parameters/esteimaxin/playback").get_current_node())

func reset()->void:
	state_machine.travel("idle")
	teleport_to_location(0,0)


func teleport_to_location(position_x: float, position_y: float)->void:
	self.position.x = position_x
	self.position.y = position_y


func gravity(delta: float)-> void:
	if jumping:
		velocity.y = JUMP_VELOCITY/2
	else:
		velocity.y = FALL_GRAVITY/4
		velocity.y = clamp(velocity.y, -FALL_SPEED, FALL_SPEED)


func move_velocity(vel:int)->void:
	if jumping:
		if randf() < 0.7 or secondjump:
			velocity.x = vel * direction * 0.5
			secondjump = false
		else:
			velocity.x = vel * direction
	else:
		velocity.x = vel * direction


func reset_attacks()->void:
	animation_tree.set(dash_attack, false)
	animation_tree.set(jump_attack, false)
	animation_tree.set(preparation, false)


func sprite_redirection() -> void:
	if global_variables.hitpoints == 0:
		state_machine.travel("win")
	else:
		direction = round((player.global_position - global_position).normalized().x)
		if direction < 0:
			$hurtbox.scale.x = -1
			$hitbox.scale.x = -1
			$animations.scale.x = -1
			$collisions.scale.x = -1
			$terraincollision.scale.x = -1
		elif direction >= 0:
			$hurtbox.scale.x = 1
			$hitbox.scale.x = 1
			$animations.scale.x = 1
			$collisions.scale.x = 1
			$terraincollision.scale.x = 1


func move_repeat()->void:
	if $collisions/WallCollision.is_colliding():
		velocity.x = 0
		animation_tree.set(preparation, true)
	else:
		animation_tree.set(preparation, false)
		state_machine.travel(animation_tree.get("parameters/esteimaxin/playback").get_current_node())


func attack()->void:
	if randf() < 0.5:
		animation_tree.set(jump_attack, true)
	else:
		animation_tree.set(dash_attack, true)


func flea_scratch()->void:
	#state_machine.travel("flea")
	pass


func second_attack()->void:
	if $collisions/PlayerCollision.is_colliding():
		state_machine.travel("dash")
	elif $collisions/WallCollision.is_colliding():
		pass
	elif !$collisions/WallCollision.is_colliding():
		state_machine.travel("jump")
		secondjump = true

