extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var SPEED = 100.0
var current_state
var ENEMY_DIRECTION
enum STATE {JUMP, WALK}

func _ready():
	current_state = STATE.WALK
	ENEMY_DIRECTION = 1
	#1 right, -1 left

func _physics_process(delta):
	enemy_gravity(delta)
	play_animations()
	enemy_movement()
	move_and_slide()

func enemy_gravity(delta):
	if !is_on_floor():
		velocity.y += GRAVITY * delta

func enemy_movement():
	if $RayCastFront.is_colliding() or !$RayCastDown.is_colliding():
		ENEMY_DIRECTION *= -1
		scale.x *= -1
	match ENEMY_DIRECTION:
		1:
			velocity.x = SPEED
		-1:
			velocity.x = SPEED * -1
	
func play_animations():
	match current_state:
		STATE.JUMP:
			animated_sprite_2d.play("flea_jump")
		STATE.WALK:
			animated_sprite_2d.play("flea_walk")

