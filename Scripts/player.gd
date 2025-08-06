extends CharacterBody2D
class_name PlayerControl

@onready var flash_shader := "res://Scenes/player.tscn::ShaderMaterial_tssud"

const WALK_SPEED: int = 130
const RUN_SPEED  : int = 200
const FALL_SPEED : int = 300
const FAST_FALL_SPEED : int = 450
const WALLJUMP_VELOCITY : int = 200
const DASH_SPEED : int = 700

const ACCELERATION : int = 700

#JUMP_HEIGHT = 0.5 * JUMP_TTRISE^2 + JUMP_VELOCITY * JUMP_TTRISE
#JUMP_VELOCITY = -GRAVITY * JUMP_HEIGHT

const JUMP_HEIGHT 	:float = 40
const JUMP_TTRISE 	:float = 0.3
const JUMP_TTFALL 	:float = 0.15
const JUMP_VELOCITY	:float =(-1) *  2 * JUMP_HEIGHT / JUMP_TTRISE
const GRAVITY		:float =(-1) * -2 * JUMP_HEIGHT / (JUMP_TTRISE * JUMP_TTRISE)
const FALL_GRAVITY 	:float =(-1) * -2 * JUMP_HEIGHT / (JUMP_TTFALL * JUMP_TTFALL)

#Numeric Variables
var CURRENT_SPEED : int
var LAST_DIRECTION = 1
var bullet_direction
var current_state : int
var last_state : int
var direction
var shift
var vertical_vel = 0
var horizontal_vel = 0

#Binary Variables 
var jump : bool = false
var double_jump : bool = false
var double_jump_buff : bool = false
var wall_jump : bool = false
var dash_reset : bool
var dash : bool
var jump_time : bool
var fast_fall : bool
var sleep : bool = false
var was_on_floor : bool = false
var jump_buffer : bool = false
var coyote_buffer : bool = false
var walking : bool = false
var wall_logic : bool = false
var jump_condition: bool = false
#SM for animations and stuff
enum STATE 	{IDLE, SLEEP, WALK, RUN, JUMP, FALL, DASH, WALL, CWALL, ASD}
const state = ["idle", "sleep", "walk", "run", "jump", "fall", "dash", "wall", "cwall", "normal_hit_1"]

var rat : AnimatedSprite2D
var weapon : AnimatedSprite2D
var ribbon : AnimatedSprite2D

func _ready():
	current_state = STATE.IDLE
	dash_reset = true
	$collisions/Hurtbox.disabled = false


func _physics_process(delta: float):
	if Input.is_action_pressed("reset"):
		global_variables.reset.emit()
	if Input.is_action_pressed("debug"):
		global_variables.debug.emit()
	wall_logic = $collisions/RayCastFrontMid.is_colliding() or ($collisions/RayCastFrontUp.is_colliding() and $collisions/RayCastFrontDown.is_colliding())
	
	player_gravity(delta)
	player_SM()
	player_idle()
	player_run(delta)
	player_dash(delta)
	player_jump()
	
	was_on_floor = is_on_floor()
	if direction != 0:
		LAST_DIRECTION = direction
	move_and_slide()


func RL_sprite_collission()->void:
	#Gira la hitbox en torno al cuerpo y no al centro del sprite
	if direction == 1:
		$collisions.scale.x = 1
		$animations.scale.x = 1
		$atacks.scale.x = 1
	if direction == -1:
		$collisions.scale.x = -1
		$animations.scale.x = -1
		$atacks.scale.x = -1


func _on_dash_duration_timer_timeout():
	dash = false

func _on_jump_timer_timeout()->void:
	jump_time = false

func _on_idle_timer_timeout()->void:
	sleep = true

func teleport_to_location(position_x: float, position_y: float)->void:
	self.position.x = position_x
	self.position.y = position_y


func player_gravity(delta: float)->void:

	if Input.is_action_pressed("down") and !is_on_floor():
		fast_fall = true
	if dash:
		velocity.y = 0
	else:
		if fast_fall:
			velocity.y += FALL_GRAVITY * delta
			velocity.y = clamp(velocity.y, -FAST_FALL_SPEED, FAST_FALL_SPEED)
		else:
			if current_state == STATE.WALL or current_state == STATE.CWALL:
				if velocity.y < 0:
					velocity.y += GRAVITY * delta
					clamp(velocity.y, -FALL_SPEED, FALL_SPEED)
				if velocity.y >= 0:
					velocity.y += FALL_GRAVITY/20 * delta
					clamp(velocity.y, -FALL_SPEED/5, FALL_SPEED/5)
			else:
				velocity.y += GRAVITY * delta
				velocity.y = clamp(velocity.y, -FALL_SPEED, FALL_SPEED)
	
	if velocity.y >= 0 and !is_on_floor():
		if was_on_floor:
			$timers/CoyoteTimer.start()
			coyote_buffer = true

	if Input.is_action_just_pressed("jump") and !is_on_floor():
		$timers/JumpBufferTimer.start()


func player_SM()->void:
	if is_on_floor() and velocity.x == 0 and !sleep:
		current_state = STATE.IDLE
		if $timers/IdleTimer.is_stopped():
			$timers/IdleTimer.start()

	if sleep:
		current_state = STATE.SLEEP

	if abs(velocity.x) <= WALK_SPEED and abs(velocity.x) > 1 and is_on_floor():
		current_state = STATE.WALK

	if abs(velocity.x) > WALK_SPEED and is_on_floor() and !is_on_wall():
		current_state = STATE.RUN

	if velocity.y < 0 and !is_on_floor():
		current_state = STATE.JUMP
	
	if velocity.y >= 0 and !is_on_floor():
		current_state = STATE.FALL

	if dash:
		current_state = STATE.DASH
	
	if (wall_logic and !is_on_floor()):
		current_state = STATE.WALL
	
	if is_on_wall():
		current_state = STATE.CWALL
		
	if Input.is_action_just_pressed("ui_BassicAttack"):
		$timers/AtackTimer.start()
	
	if !$timers/AtackTimer.is_stopped():
		current_state = STATE.ASD
	
	last_state = current_state
	global_variables.state_signal.emit(state[current_state])


func player_run(delta: float)->void:
	direction = Input.get_axis("left", "right")
	walking = Input.is_action_pressed("walking")
	if is_on_floor() and $timers/DashResetTimer.is_stopped():
		dash_reset = true
	RL_sprite_collission()
	CURRENT_SPEED = RUN_SPEED
	
	if walking:
		CURRENT_SPEED = WALK_SPEED
	if  dash:
		velocity.x = LAST_DIRECTION * DASH_SPEED 
	#este comentario es para la aceleracion, pero el movement se siente pesado
	#if direction != LAST_DIRECTION and !dash:
		#velocity.x = move_toward(velocity.x, direction * 1/5*RUN_SPEED, 5*ACCELERATION * delta)
	#elif direction != 0 and !dash:
		#velocity.x = move_toward(velocity.x, direction * RUN_SPEED, ACCELERATION * delta)
	elif direction:
		velocity.x = RUN_SPEED * direction
	elif wall_jump:
		velocity.x = 2 * RUN_SPEED * direction
	else:
		velocity.x = 0


func player_jump()->void:
	if (jump_logic() or wall_jump_logic() or double_jump_logic()):
		velocity.y = JUMP_VELOCITY
		$timers/JumpTimer.start()
	
	#Esta parte de abajo controla el que puedas saltar mientras mantienes el boton
	if Input.is_action_pressed("jump") and !$timers/JumpTimer.is_stopped():
		velocity.y = JUMP_VELOCITY
	#if Input.is_action_just_released("jump") and $timers/JumpTimer.is_stopped() and velocity.y < 0:
		#velocity.y = 0


func jump_logic()->bool:
	jump = is_on_floor() or coyote_buffer
	if jump and (Input.is_action_just_pressed("jump") or !$timers/JumpBufferTimer.is_stopped()):
		fast_fall = false
		jump = false
		coyote_buffer = false
		return true
		
	return false


func double_jump_logic()->bool:
	if !global_variables.double_jump:
		return false
	if is_on_floor():
		double_jump = true
		pass
	if (wall_logic and Input.is_action_just_pressed("jump")) or !$timers/WallJumpTimer.is_stopped() or !$timers/CoyoteTimer.is_stopped():
		return false
	if double_jump and !is_on_floor() and Input.is_action_just_pressed("jump"):
		double_jump = false
		fast_fall = false
		return true
	return false


func wall_jump_logic()->bool:
	if !global_variables.wall_jump:
		return false
	if current_state == STATE.WALL:
		$timers/WallJumpTimer.start()
		pass
	if !$timers/WallJumpTimer.is_stopped() and direction != 0 and !is_on_wall() and  Input.is_action_just_pressed("jump"):
		velocity.x = WALLJUMP_VELOCITY * direction
		return true
	return false


func player_dash(delta: float)->void:
	if !global_variables.dash:
		return
	if is_on_floor() and $timers/DashResetTimer.is_stopped():
		dash_reset = true
	if Input.is_action_just_pressed("dash") and dash_reset: # and is_on_floor():
		$timers/DashDurationTimer.start()
		$timers/DashResetTimer.start()
		velocity.y = 0
		dash = true
		dash_reset = false


func player_idle()->void:
	if current_state != STATE.SLEEP and current_state != STATE.IDLE:
		sleep = false


