extends CharacterBody2D
var player: PlayerControl

enum STATE {IDLE, CHASE, MELEEATT, RANGEATT, STUNNED}
enum ATTACK {MELEE, RANGE}
const state = ["idle","chase","meleeatt","rangeatt","stunned"]

const GRAVITY := 700
const FALL_SPEED := 400
const MELLEATT_DISTANCE := 50
const RANGEATT_DISTANCE := 300
const SPEED := 100

var current_state: int = STATE.IDLE
var next_state: int = STATE.IDLE
var attack_type: int = ATTACK.MELEE

var can_attack: bool = true

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float):
	handle_state(delta)
	state_machine()
	move_and_slide()
	play_animations()
	gravity(delta)

func gravity(delta: float)-> void:
	velocity.y += GRAVITY * delta
	velocity.y = clamp(velocity.y, -FALL_SPEED, FALL_SPEED)


func handle_state(delta: float)-> void:
	#que hace cada estado
	#print(state[current_state])
	match current_state:
		STATE.IDLE:
			velocity.x = 0
		STATE.CHASE:
			chase_player(delta)
		STATE.MELEEATT:
			melee_attack()
		STATE.RANGEATT:
			ranged_attack()
		STATE.STUNNED:
			velocity.x = 0
			#$animations/AnimationPlayer.play("stunned")

func state_machine()-> void:
	#condiciones para asignar el estado
	var dis = abs(global_position.distance_to(player.global_position))
	#distancia entre voss y player	
	match current_state:
		STATE.CHASE:
			if dis <= MELLEATT_DISTANCE:
				next_state = STATE.MELEEATT
			elif dis > RANGEATT_DISTANCE:
				next_state = STATE.RANGEATT
		STATE.MELEEATT:
			if !$timers/MeleeAttTimer.is_stopped():
				pass
			else:
				next_state = STATE.IDLE
				$timers/IdleTimer.start()
				can_attack = true
		STATE.RANGEATT:
			if !$timers/RangeAttTimer.is_stopped():
				pass
			else:
				next_state = STATE.IDLE
				$timers/IdleTimer.start()
				can_attack = true
		STATE.IDLE:
			if $timers/IdleTimer.is_stopped():
				if dis <= MELLEATT_DISTANCE:
					next_state = STATE.MELEEATT
				elif dis > RANGEATT_DISTANCE:
					next_state = STATE.RANGEATT
				else:
					next_state = STATE.CHASE
	
	current_state = next_state

func chase_player(delta: float) -> void:
	var direction = (player.global_position - global_position).normalized().x
	velocity.x = direction * SPEED

func melee_attack() -> void:
	if !can_attack: return
	else:
		velocity.x = 0
		can_attack = false
		$timers/MeleeAttTimer.start()

func ranged_attack() -> void:
	if !can_attack: return
	else:
		can_attack = false
		$timers/RangeAttTimer.start()#animacino
		$timers/RangeAttTimer/Teleport.start()

func play_animations() -> void:
	var direction:float = (player.global_position - global_position).normalized().x
	$animations/AnimationPlayer.play(state[current_state])
	if direction < 0:
		$hurtbox.position.x = 4
		$hurtbox.scale.x = -1
		$animations.scale.x = -1
		#$atacks.scale.x = 1
	elif direction >= 0:
		$hurtbox.position.x = -4
		$hurtbox.scale.x = 1
		$animations.scale.x = 1
		#$atacks.scale.x = 1
	
func cat_teleport(position_x: float, position_y: float)->void:
	self.position.x = position_x
	self.position.y = position_y
#func _on_attack_timeout() -> void:
	#can_attack = true


func _on_teleport_timeout():
	var direction:float = (player.global_position - global_position).normalized().x
	if direction < 0:
			cat_teleport(player.global_position.x - 50, player.global_position.y)
	elif direction > 0:
			cat_teleport(player.global_position.x + 50, player.global_position.y)
