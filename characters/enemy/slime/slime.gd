extends enemy

func _ready():
	maxVelocityX = 20
	patrolArea = [Vector2(168, 144), Vector2(345, 144)]
	
	characterName = "Slime"

func _physics_process(delta):
	_physics_processEn(delta, ["moveToPlayer", "patrol"])
	updateAnimation(["idle", "walk"])
	updateAnimationEnemy()
	
	if sees_player():
		slimeMoveToPlayer()
	else:
		patrol()

func updateAnimationEnemy():
	if jumping and on_ground:
		$AnimatedSprite.play("jump_prepare")
	else:
		if velocity.x != 0 and velocity.y == 0:
			$AnimatedSprite.play("walk")
			if velocity.x < 0:
				$AnimatedSprite.flip_h = true
			else:
				$AnimatedSprite.flip_h = false
		if velocity.x == 0 and on_ground:
			$AnimatedSprite.play("idle")

func slimeMoveToPlayer():
	if pos.x > player.pos.x:
		if pos.x - player.pos.x <= attackRange and velocity.x < 0:
			jumpNew("left")
		else:
			moveDirection("left", 40)
		
	if pos.x < player.pos.x:
		if player.pos.x - pos.x <= attackRange and velocity.x > 0:
			jumpNew("right")
		else:
			moveDirection("right", 40)

func jumpNew(direction):
	if on_ground and not jumping:
		jumping = true
		yield($AnimatedSprite, "animation_finished")
		velocity.y = jump_force
		
		if direction == "left":
			velocity.x = -maxVelocityX * 4
		elif direction == "right":
			velocity.x = maxVelocityX * 4
		else:
			velocity.x = 0
	elif on_ground:
		jumping = false