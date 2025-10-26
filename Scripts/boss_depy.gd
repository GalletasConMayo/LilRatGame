extends CharacterBody2D
class_name Enemy

const jump_attack = "parameters/esteimaxin/conditions/jump_attack"
const dash_attack = "parameters/esteimaxin/conditions/dash_attack"
const wall_attack = "parameters/esteimaxin/conditions/wall_attack"
const one_jump = "parameters/esteimaxin/jump/conditions/one_jump"
const two_jump_1 = "parameters/esteimaxin/jump/conditions/two_jump_1"
const two_jump_2 = "parameters/esteimaxin/jump/conditions/two_jump_2"
const special_jump = "parameters/esteimaxin/jump/conditions/special_jump"
const single_dash = "parameters/esteimaxin/dash/conditions/single_dash"
const double_dash = "parameters/esteimaxin/dash/conditions/double_dash"
const special_dash = "parameters/esteimaxin/dash/conditions/special_dash"
const jump_return = "parameters/esteimaxin/conditions/jump_return"
const dash_return = "parameters/esteimaxin/conditions/dash_return"
const dash_wall = "parameters/esteimaxin/wall/conditions/dash_wall"
const turn_dash_wall = "parameters/esteimaxin/wall/conditions/turn_dash_wall"
var vector_direction: Vector2
var wall_vector_dir: Vector2
var player: PlayerControl
var scratch_prob:float
var HP:int

var scratch_secuence:int
var transition_count:int= 0
var flea_count:int = 0
var direction:int = 0
var last_direction:int = 0
var jump_type:String
var dash_type:String
var wall1:bool
var special:bool
@export var jumping:bool = false

@onready var animations = $animations/AnimationPlayer
@onready var animation_tree = $animations/AnimationTree
@onready var state_machine = animation_tree["parameters/esteimaxin/playback"]

const RUN_SPEED  : int = 640 - 180
const DASH_SPEED : int = 640
const FALL_SPEED : int = 400

var JUMP_HEIGHT :float = 320 - (5*16) - 95
var JUMP_TTRISE :float = 0.5
var JUMP_TTFALL :float = 0.5

@onready var JUMP_VELOCITY	:float =(-1) *  (2 * JUMP_HEIGHT) / JUMP_TTRISE
@onready var RISE_GRAVITY	:float =(-1) * (-2 * JUMP_HEIGHT) / (JUMP_TTRISE * JUMP_TTRISE)
@onready var FALL_GRAVITY 	:float =(-1) * (-2 * JUMP_HEIGHT) / (JUMP_TTFALL * JUMP_TTFALL)

const DAMAGE: int = 1

func _ready():
	HP = 20
	player = get_tree().get_first_node_in_group("player")
	await get_tree().create_timer(2).timeout
	global_variables.reset.connect(reset)


func _physics_process(delta: float):
	gravity(delta)
	$hurtbox.hp_check()
	if Input.is_action_just_pressed("test"):
		state_machine.travel("win")
		self.position = get_parent().get_node("test_pos").position
		await get_tree().create_timer(2).timeout

	move_and_slide()
	#print(animation_tree.get("parameters/esteimaxin/playback").get_current_node())


func next_attack()->void:
	#var path = randf()
	var path = 0.7
	if  0 <= path and path <= 0.33:
		SM_condition(jump_attack)
	elif 0.33 < path and path <= 0.66:
		SM_condition(dash_attack)
	elif 0.66 < path and path <= 1:
		SM_condition(wall_attack)
		last_direction = direction


func prep_jump()->void:
	#var path = randf()
	var path = 0.9
	if  0 < path and path <= 0.25:
		SM_condition(one_jump)
		jump_type = "single"
	elif 0.25 < path and path <= 0.5:
		SM_condition(two_jump_1)
		jump_type = "double"
	elif 0.5 < path and path <= 0.75:
		SM_condition(two_jump_2)
		jump_type = "double"
		last_direction = direction
	elif 0.75 < path and path <= 1:
		SM_condition(special_jump)
		jump_type = "special"
		scratch_secuence = 0


func jump()->void:
	JUMP_HEIGHT = 320 - (5*16) - 95
	JUMP_TTRISE = 0.5
	JUMP_TTFALL = 0.5
	velocity.y = JUMP_VELOCITY
	jumping = true
	match jump_type:
		"single":
			velocity.x = (RUN_SPEED * direction)-10
		"double":
			velocity.x = ((RUN_SPEED * direction)-20) / 2
		"special":
			velocity.x = ((RUN_SPEED * direction)-20) / 2
		_:
			print("le pele a algo en jump")
			pass


func prep_dash()->void:
	#var path = randf()
	var path = 0.9
	if  0 <= path and path <= 0.33:
		SM_condition(single_dash)
		dash_type = "single"
	elif 0.33 < path and path <= 0.66:
		SM_condition(double_dash)
		dash_type = "double"
		last_direction = direction
	elif 0.66 < path and path <= 1:
		SM_condition(special_dash)
		dash_type = "special"
		scratch_secuence = 0


func dash()->void:
	match dash_type:
		"single":
			velocity.x = direction * DASH_SPEED * 2
		"double":
			velocity.x = direction * DASH_SPEED
		"special":
			velocity.x = direction * DASH_SPEED * 2
		"return":
			velocity.x = direction * DASH_SPEED * 2
		"wall":
			velocity.x = 2 * DASH_SPEED * abs(1-(wall_vector_dir.x/640)) * direction
		"turn_wall":
			velocity.x = 2 * DASH_SPEED * (wall_vector_dir.x/640) * -1

		_:
			print("le pele a algo en dash")
			pass


func scratch()->void:
	if scratch_secuence == 0:
		state_machine.travel("scratch")
		scratch_prob = 0
		scratch_secuence += 1
	else:
		pass


func repeat_scratch()->void:
	if scratch_prob > 3:
		pass
	else:
		scratch_prob += randf()
		state_machine.travel("scratch")


func prep_return()->void:
	var path  = randf()
	if path > 0.5:
		SM_condition(jump_return)
	else:
		SM_condition(dash_return)
		dash_type = "return"
	
func wall(secuence:int)->void:
	match secuence:
		0:
			velocity.y =  JUMP_VELOCITY
			velocity.x = -1 * direction * 200
		1:
			wall1 = true
		2:
			wall1 = false
			wall_vector_dir = (player.global_position - global_position)
			velocity.x = 2 * DASH_SPEED * wall_vector_dir.x / 640
		3:
			if abs(wall_vector_dir.x) < 300:
				SM_condition(dash_wall)
				dash_type = "wall"
			else:
				SM_condition(turn_dash_wall)
				dash_type = "turn_wall"


func vel_x_change(num:int)->void:
	velocity.x = num * direction


func gravity(delta)->void:
	if wall1:
		velocity.y = 0
	if jumping:
		velocity.y += RISE_GRAVITY * delta
		if velocity.y < 0.0: jumping = false
	else:
		velocity.y += FALL_GRAVITY * delta
		clamp(velocity.y, -FALL_SPEED, FALL_SPEED)


func reset()->void:
	state_machine.travel("idle")
	teleport_to_location(0,0)


func teleport_to_location(position_x: float, position_y: float)->void:
	self.position.x = position_x
	self.position.y = position_y


func sprite_redirection() -> void:
	vector_direction = (player.global_position - global_position)
	direction = round(vector_direction.normalized().x)
	if animation_tree[two_jump_2] or animation_tree[double_dash]:
		if last_direction == direction:
			direction *= -1

	if direction < 0:
		$hurtbox.scale.x = -1
		$hitbox.scale.x = -1
		$animations.scale.x = -1
		$terraincollision.scale.x = -1
	elif direction >= 0:
		$hurtbox.scale.x = 1
		$hitbox.scale.x = 1
		$animations.scale.x = 1
		$terraincollision.scale.x = 1


func SM_condition(condition:String)->void:
	animation_tree[condition] = true
	await get_tree().create_timer(0.5).timeout
	animation_tree[condition] = false


####### OLD STUFF ###########


#func move_velocity(vel:int)->void:
	#if jumping:
		#if randf() < 0.7 or secondjump:
			#velocity.x = vel * direction * 0.5
			#secondjump = false
		#else:
			#velocity.x = vel * direction
	#else:
		#velocity.x = vel * direction


#func move_repeat()->void:
	#if $collisions/WallCollision.is_colliding():
		#velocity.x = 0
		#animation_tree.set(preparation, true)
	#else:
		#animation_tree.set(preparation, false)
		#state_machine.travel(animation_tree.get("parameters/esteimaxin/playback").get_current_node())

#
#func attack()->void:
	#if randf() < 0.5:
		#animation_tree.set(jump_attack, true)
	#else:
		#animation_tree.set(dash_attack, true)

#	
#func second_attack()->void:
	#if $collisions/PlayerCollision.is_colliding():
		#state_machine.travel("dash")
	#elif $collisions/WallCollision.is_colliding():
		#pass
	#elif !$collisions/WallCollision.is_colliding():
		#state_machine.travel("jump")
		#secondjump = true
