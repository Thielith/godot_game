extends character

var direction : int = 0

func _physics_process(delta):
	enableGravity(delta)

func _process(delta):
	input_process()
	move(direction)

func input_process():
	direction = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	
	if Input.is_action_just_pressed("jump"):
		if ground_raycast.is_colliding():
			jump()
		if direction != slope_direction and slope_direction != 0:
			jump()
	
	if Input.is_action_pressed("interact"):
		print(wasOnSlope)
		