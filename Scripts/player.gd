extends CharacterBody2D
class_name PlayerControl

const WALK_SPEED: int = 130
const RUN_SPEED  : int = 200
const FALL_SPEED : int = 300
const FAST_FALL_SPEED : int = 450

const ACCELERATION : int = 700
const DEACCELERATION : int = 800

const DASH_SPEED : int = 500
const INITIAL_SPEED : int = 80

#JUMP_HEIGHT = 0.5 * JUMP_TTRISE^2 + JUMP_VELOCITY * JUMP_TTRISE
#JUMP_VELOCITY = -GRAVITY * JUMP_HEIGHT

const JUMP_HEIGHT 	:float = 40
const JUMP_TTRISE 	:float = 0.3
const JUMP_TTFALL 	:float = 0.15
const JUMP_VELOCITY	:float =(-1) *  2 * JUMP_HEIGHT / JUMP_TTRISE
const RISE_GRAVITY	:float =(-1) * -2 * JUMP_HEIGHT / (JUMP_TTRISE * JUMP_TTRISE)
const FALL_GRAVITY 	:float =(-1) * -2 * JUMP_HEIGHT / (JUMP_TTFALL * JUMP_TTFALL)

const WALLJUMP_VELOCITY : int = 300

#Numeric Variables
var CURRENT_SPEED : int
var LAST_DIRECTION = 1
var DASH_DIRECTION
var HP
var DAMAGE
var SPEED
var bullet_direction
var current_state
var direction
var shift
var vertical_vel = 0
var horizontal_vel = 0

#Binary Variables *true/false
var jump : bool = false
var double_jump : bool = false
var double_jump_buff : bool = false
var wall_jump : bool = false
var dash_reset : bool
var dash : bool
var jump_time : bool
var double_jump_time : bool
var fast_fall : bool
var sleep : bool = false
var was_on_floor : bool = false
var jump_buffer : bool = false
var coyote_buffer : bool = false
var walking : bool = false
var wall_logic : bool = false
var jump_condition: bool = false
#SM for animations and stuff
enum STATE 	{IDLE, SLEEP, WALK, RUN, JUMP, FALL, DASH, WALL, CWALL}
const state = ["idle", "sleep", "walk", "run", "jump", "fall", "dash", "wall", "cwall"]

var rat : AnimatedSprite2D
var weapon : AnimatedSprite2D
var ribbon : AnimatedSprite2D
 
func _ready():
	rat = $player_collision/rat
	weapon = $player_collision/weapon
	ribbon = $player_collision/ribbon
	current_state = STATE.IDLE
	dash_reset = true
	$player_collision.disabled = false
	$player_collision.position.x = -6
	HP = 10
	DAMAGE = 1
	SPEED = 0

func _physics_process(delta):
	if Input.is_action_pressed("reset"):
		global_variables.reset.emit()
	if Input.is_action_pressed("debug"):
		global_variables.debug.emit()
		
	player_gravity(delta)
	player_SM()
	player_idle()
	player_run(delta)
	player_dash(delta)
	player_jump()
	#jump_logic()
	#double_jump_logic()
	#wall_jump_logic()
	play_animations()
	was_on_floor = is_on_floor()
	LAST_DIRECTION = direction
	move_and_slide()


func player_gravity(delta)->void:
#Esto creo que era para que girara la ratita, pero gira con hitbox y actua raro
#	if !is_on_floor():
#		if SPIN == 1:
#			$AnimatedSprite2D.rotate(PI/6)
#		elif SPIN == -1:
#			$AnimatedSprite2D.rotate(-PI/6)
#		elif SPIN == -0:
#			$AnimatedSprite2D.set_rotation(0)

	if Input.is_action_pressed("down") and !is_on_floor():
		fast_fall = true
	if dash:
		velocity.y = 0
	else:
		if fast_fall:
			velocity.y += FALL_GRAVITY * delta
			velocity.y = clamp(velocity.y, -FAST_FALL_SPEED, FAST_FALL_SPEED)
		else:
			if current_state == STATE.WALL:
				velocity.y = clamp(velocity.y, -FALL_SPEED/16, FALL_SPEED/16)
			else:
				velocity.y += RISE_GRAVITY * delta
				velocity.y = clamp(velocity.y, -FALL_SPEED, FALL_SPEED)
	
	if velocity.y >= 0 and !is_on_floor():
		if was_on_floor:
			$CoyoteTimer.start()
			coyote_buffer = true

	if Input.is_action_just_pressed("jump") and !is_on_floor():
		$JumpBufferTimer.start()

func player_SM()->void:
	if is_on_floor() and velocity.x == 0 and !sleep:
		current_state = STATE.IDLE
		if $IdleTimer.is_stopped():
			$IdleTimer.start()

	if sleep:
		current_state = STATE.SLEEP

	if abs(velocity.x) <= WALK_SPEED and abs(velocity.x) > 1 and is_on_floor():
		current_state = STATE.WALK

	if abs(velocity.x) > WALK_SPEED and is_on_floor():
		current_state = STATE.RUN

	if velocity.y < 0 and !is_on_floor():
		current_state = STATE.JUMP
	
	if velocity.y >= 0 and !is_on_floor():
		current_state = STATE.FALL

	if dash:
		current_state = STATE.DASH
	
	if (wall_logic and !is_on_floor()):
		current_state = STATE.WALL

	if !$WallJumpTimer.is_stopped() and wall_logic:
		current_state = STATE.CWALL



func player_run(delta)->void:
	direction = Input.get_axis("left", "right")
	walking = Input.is_action_pressed("walking")
	if is_on_floor() and $DashResetTimer.is_stopped():
		dash_reset = true
	RL_sprite_collission()
	CURRENT_SPEED = RUN_SPEED
	
	if walking:
		CURRENT_SPEED = WALK_SPEED

	if direction != 0 and !dash:
		velocity.x = move_toward(velocity.x, direction * RUN_SPEED, ACCELERATION * delta)

	elif dash:
		velocity.x = DASH_DIRECTION * DASH_SPEED 

	elif wall_jump:
		velocity.x = 2 * RUN_SPEED * direction

	else:
		velocity.x = 0

func player_jump()->void:
	jump_logic()
	double_jump_logic()
	wall_jump_logic()
	#Aqui se ve la logica para ver si el salto es normal, doble, wall, etc
	jump_condition =  (jump  or  wall_jump  or  double_jump)
	
	if (Input.is_action_just_pressed("jump") and jump_condition) or (is_on_floor() and !$JumpBufferTimer.is_stopped()):
		if jump:
			jump = false
			print("jump")
		if double_jump:
			print("doublejump")
			double_jump = false
		if wall_jump:
			print("walljump")
			double_jump = true
			wall_jump = false
		velocity.y = JUMP_VELOCITY
		$JumpTimer.start()
		$MinJumpTimer.start()
		coyote_buffer = false
	#Esta parte de abajo controla el que puedas saltar mientras mantienes el boton
	if Input.is_action_pressed("jump") and !$JumpTimer.is_stopped(): # and is_on_floor():
		velocity.y = JUMP_VELOCITY
	#Esto controla la velocidad de caida
	if Input.is_action_just_released("jump") and $MinJumpTimer.is_stopped():
		velocity.y = 0

func jump_logic()->void:
	jump = is_on_floor() or coyote_buffer
	if jump:
		fast_fall = false
		

func double_jump_logic()->void:
	if !global_variables.double_jump:
		return
	if is_on_floor():
		double_jump = true
	if wall_logic and Input.is_action_pressed("jump"):
		double_jump = false
		return
	if !$WallJumpTimer.is_stopped() or !$CoyoteTimer.is_stopped():
		double_jump = false
		return
	if double_jump and !is_on_floor() and Input.is_action_just_pressed("jump"):
		double_jump = false

func wall_jump_logic()->void:
	wall_logic = $player_collision/RayCastFrontMid.is_colliding() or ($player_collision/RayCastFrontUp.is_colliding() and $player_collision/RayCastFrontDown.is_colliding())

	if !global_variables.wall_jump:
		return
	if current_state == STATE.WALL:
		$WallJumpTimer.start()
	if !$WallJumpTimer.is_stopped() and direction != 0 and !is_on_wall():
		wall_jump = true

func player_dash(delta)->void:
	if !global_variables.dash:
		return

	if Input.is_action_just_pressed("dash") and dash_reset: # and is_on_floor():
		DASH_DIRECTION = direction
		$DashDurationTimer.start()
		$DashResetTimer.start()
		velocity.y = 0
		velocity.x = DASH_DIRECTION * DASH_SPEED
		dash_reset = false
		dash = true

func player_idle()->void:
	if current_state != STATE.SLEEP and current_state != STATE.IDLE:
		sleep = false
		
func play_animations()->void:
	ribbon.visible = global_variables.ribbon
	weapon.visible = global_variables.weapon
	for member in state:
		if member == state[current_state]:
			if member == "cwall" or member == "dash":
				pass
			else:
				rat.play("rat_"+member)
				ribbon.play("ribbon_"+member)
				weapon.play("weapon_"+member)

func RL_sprite_collission()->void:
	#Esto de aqui esta un poco mucho hardcodeado, pq hacerlo funcion estaba medio paja
	#Gira la hitbox en torno al cuerpo y no al centro del sprite
	if direction == 1:
		$player_collision.position.x = -6
		$player_collision.scale.x = 1
	if direction == -1:
		$player_collision.position.x = 6
		$player_collision.scale.x = -1

func _on_dash_timer_timeout()->void:
	dash = false

func _on_dash_reset_timer_timeout()->void:
	if is_on_floor():
		dash_reset = true

func _on_jump_timer_timeout()->void:
	jump_time = false

func _on_double_jump_timer_timeout()->void:
	double_jump_time = false

func _on_idle_timer_timeout()->void:
	sleep = true

func teleport_to_location(position_x, position_y)->void:
	self.position.x = position_x
	self.position.y = position_y
