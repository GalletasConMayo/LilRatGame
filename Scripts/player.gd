extends CharacterBody2D
class_name PlayerControl

@onready var flash_shader := "res://Scenes/player.tscn::ShaderMaterial_tssud"

const WALK_SPEED: int = 130
const RUN_SPEED  : int = 180
const FALL_SPEED : int = 500
const WALLJUMP_VELOCITY : int = 200
const DASH_SPEED : int = 700

const ACCELERATION : int = 700

#JUMP_HEIGHT = 0.5 * JUMP_TTRISE^2 + JUMP_VELOCITY * JUMP_TTRISE
#JUMP_VELOCITY = -GRAVITY * JUMP_HEIGHT

const JUMP_HEIGHT 	:float = 100
const JUMP_TTRISE 	:float = 0.4		#tiempo altura maxima
const JUMP_TTFALL 	:float = 0.3	
const JUMP_VELOCITY	:float =(-1) *  2 * JUMP_HEIGHT / JUMP_TTRISE
const RISE_GRAVITY	:float =(-1) * -2 * JUMP_HEIGHT / (JUMP_TTRISE * JUMP_TTRISE)
const FALL_GRAVITY 	:float =(-1) * -2 * JUMP_HEIGHT / (JUMP_TTFALL * JUMP_TTFALL)

const GRAVITY:int = 400

#Numeric Variables
var HP: int
var MAX_HP: int
var DAMAGE: int
var CURRENT_SPEED : int
var LAST_DIRECTION : int = 1
var current_state : String
var last_state : String
var direction
var vertical_vel = 0
var horizontal_vel = 0
var wip_count = 0
#Binary Variables 
var can_control : bool = true
var jump : bool = false
var double_jump : bool = false
var double_jump_buff : bool = false
var wall_jump : bool = false
var dash_reset : bool
var dash : bool
var jump_time : bool
var sleep : bool = false
var was_on_floor : bool = false
var jump_buffer : bool = false
var coyote_buffer : bool = false
var wall_logic : bool = false
var jump_condition: bool = false
var can_wip: bool = true
var wip: bool = false
var attack_2: bool = false
var wip_up:bool = false
var wip_down:bool = false
var jump_release:bool = false

var rat : AnimatedSprite2D
var weapon : AnimatedSprite2D
var ribbon : AnimatedSprite2D

func _ready():
	HP = 5
	current_state = "idle"
	dash_reset = true
	await get_tree().create_timer(0.1).timeout
	global_variables.first_hp_anim.emit(HP)


func _physics_process(delta: float):
	if Input.is_action_pressed("reset"):
		global_variables.reset.emit()
	if Input.is_action_pressed("debug"):
		global_variables.debug.emit()
	wall_logic = $collisions/RayCastFrontMid.is_colliding() or ($collisions/RayCastFrontUp.is_colliding() and $collisions/RayCastFrontDown.is_colliding())
	
	if can_control:
		player_gravity(delta)
		player_SM()
		player_idle()
		player_movement(delta)
		player_dash()
		player_jump()
		player_attack()

	was_on_floor = is_on_floor()
	if direction != 0:
		LAST_DIRECTION = direction
	move_and_slide()


func RL_sprite_collission()->void:
	#Gira la hitbox en torno al cuerpo y no al centro del sprite
	if direction == 1:
		$collisions.scale.x = 1
		$animations.scale.x = 1
		$hutrbox.scale.x = 1
		$hitbox.scale.x = 1
	if direction == -1:
		$collisions.scale.x = -1
		$animations.scale.x = -1
		$hutrbox.scale.x = -1
		$hitbox.scale.x = -1

func _on_control_after_damage_timeout() -> void:
	can_control = true

func _on_dash_duration_timer_timeout()->void:
	dash = false

func _on_jump_timer_timeout()->void:
	jump_time = false

func _on_idle_timer_timeout()->void:
	sleep = true

func _on_attack_CD_timeout():
	can_wip = true

func _on_attack_lock_timeout():
	wip = false
	wip_up = false
	wip_down = false

func teleport_to_location(position_x: float, position_y: float)->void:
	self.position.x = position_x
	self.position.y = position_y

func move_x(vel_x: float, time: float)->void:
	self.velocity.x = vel_x

func reset()->void:
	can_control = true
	$animations.visible = true
	HP = 10000


func player_SM()->void:
	if is_on_floor() and velocity.x == 0 and !sleep:
		current_state = "idle"
		if $timers/Idle.is_stopped():
			$timers/Idle.start()

	if sleep:
		current_state = "sleep"

	if abs(velocity.x) > WALK_SPEED and is_on_floor() and !is_on_wall():
		current_state = "run"

	if velocity.y < 0 and !is_on_floor():
		current_state = "jump"
	
	if velocity.y >= 0 and !is_on_floor():
		current_state = "fall"

	if dash:
		current_state = "dash"
	
	if wip:
		if wip_count == 0:
			current_state = "wip1"
		else:
			current_state = "wip2"
	
	if wip_up:
		current_state = "wipup"
	
	if wip_down:
		current_state = "wipdown"

	if (wall_logic and !is_on_floor()):
		current_state = "wall"
	
	if is_on_wall():
		current_state = "cwall"
	
	last_state = current_state
	global_variables.state_signal.emit(current_state)


func player_gravity(delta: float)->void:

	if dash:
		velocity.y = 0
	else:
		if current_state == "wall" or current_state == "cwall":
			if velocity.y < 0:
				velocity.y += GRAVITY * delta
				clamp(velocity.y, -FALL_SPEED, FALL_SPEED)
			if velocity.y >= 0:
				velocity.y += FALL_GRAVITY/20 * delta
				clamp(velocity.y, -FALL_SPEED/5, FALL_SPEED/5)
		else:
			if velocity.y < 0:
				velocity.y += RISE_GRAVITY * delta
			else:
				velocity.y += FALL_GRAVITY * delta
				velocity.y = clamp(velocity.y, -FALL_SPEED, FALL_SPEED)

	if velocity.y >= 0 and !is_on_floor():
		if was_on_floor:
			$timers/Coyote.start()
			coyote_buffer = true

	if Input.is_action_just_pressed("jump") and !is_on_floor():
		$timers/JumpBuffer.start()


func player_movement(delta: float)->void:
	direction = Input.get_axis("left", "right")
	if is_on_floor() and $timers/DashReset.is_stopped():
		dash_reset = true
	RL_sprite_collission()
	CURRENT_SPEED = RUN_SPEED
	
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
	if velocity.y > 0: jump_release = false
	if (jump_logic() or wall_jump_logic() or double_jump_logic()):
		velocity.y = JUMP_VELOCITY
		$timers/Jump.start()
	
	#Esta parte de abajo controla el que puedas saltar mientras mantienes el boton
	if Input.is_action_just_released("jump") and jump_release:
		velocity.y = -100
		jump_release = false
	#if Input.is_action_just_released("jump") and $timers/Jump.is_stopped() and velocity.y < 0:
		#velocity.y = 0


func jump_logic()->bool:
	jump = is_on_floor() or coyote_buffer
	if jump and (Input.is_action_just_pressed("jump") or !$timers/JumpBuffer.is_stopped()):
		jump_release = true
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
	if (wall_logic and Input.is_action_just_pressed("jump")) or !$timers/WallJump.is_stopped() or !$timers/Coyote.is_stopped():
		return false
	if double_jump and !is_on_floor() and Input.is_action_just_pressed("jump"):
		double_jump = false
		return true
	return false


func wall_jump_logic()->bool:
	if !global_variables.wall_jump:
		return false
	if current_state == "wall":
		$timers/WallJump.start()
		pass
	if !$timers/WallJump.is_stopped() and direction != 0 and !is_on_wall() and  Input.is_action_just_pressed("jump"):
		velocity.x = WALLJUMP_VELOCITY * direction
		return true
	return false


func player_dash()->void:
	if !global_variables.dash:
		return
	if is_on_floor() and $timers/DashReset.is_stopped():
		dash_reset = true
	if Input.is_action_just_pressed("dash") and dash_reset: # and is_on_floor():
		$timers/DashDuration.start()
		$timers/DashReset.start()
		velocity.y = 0
		dash = true
		dash_reset = false


func player_attack()->void:
	if can_wip:
		if Input.is_action_just_pressed("attack"): #and $timers/attacks/Lock.is_stopped():
			$timers/attacks/CD.start()
			can_wip = false
			wip = true
			if wip_count != 0: wip_count = 0
			else: wip_count +=1
			
		if Input.is_action_just_pressed("attack") and Input.is_action_pressed("up"):
			$timers/attacks/CD.start()
			can_wip = false
			wip_up = true
		
		if Input.is_action_just_pressed("attack") and Input.is_action_pressed("down") and !is_on_floor():
			$timers/attacks/CD.start()
			can_wip = false
			wip_down = true
			
		$timers/attacks/Lock.start()


func player_idle()->void:
	if current_state != "sleep" and current_state != "idle":
		sleep = false
