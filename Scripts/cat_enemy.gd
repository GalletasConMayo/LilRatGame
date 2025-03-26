extends CharacterBody2D

var GRAVITY = 100
var SPEED = 100
var current_state
var ENEMY_DIRECTION
enum STATE {JUMP, WALK}

func _process(delta):
	if $AttackTimer.is_stopped():
		$AttackTimer.start()
	if !$AttackTimer.is_stopped():
		$AnimationPlayer.play("cat_attack")
	
	enemy_gravity(delta)
	enemy_movement()
	move_and_slide()


func enemy_gravity(delta):
	if !is_on_floor():
		velocity.y += GRAVITY * delta

func enemy_movement():
	pass
	#if $RayCastFront.is_colliding() or !$RayCastDown.is_colliding():
		#ENEMY_DIRECTION *= -1
		#scale.x *= -1
	#match ENEMY_DIRECTION:
		#1:
			#velocity.x = SPEED
		#-1:
			#velocity.x = SPEED * -1


func _on_cat_hitbox_body_entered(body):
	if body is PlayerControl:
		print("XD")
