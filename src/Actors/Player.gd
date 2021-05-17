extends Actor

func _physics_process(delta) -> void:
	move_direction();
	velocity = speed * direction.normalized();
	velocity = move_and_slide(velocity);
	
func move_direction() -> void:
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left");  
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up");



   

