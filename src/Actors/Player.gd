extends Actor

func _physics_process(delta) -> void:
	get_direction();
	_velocity = calculate_move_velocity(_velocity);
	_velocity = move_and_slide(_velocity);
	_direction = Vector2.ZERO;
	
func get_direction():
	if Input.is_action_pressed("move_down"):
		_direction.y += 1;
	if Input.is_action_pressed("move_up"):
		_direction.y -= 1;
	if Input.is_action_pressed("move_left"):
		_direction.x -= 1;
	if Input.is_action_pressed("move_right"):
		_direction.x += 1;
	
func calculate_move_velocity(velocity: Vector2) -> Vector2:
	velocity = _direction;
	var new_velocity = velocity.normalized() * speed;
	return new_velocity
