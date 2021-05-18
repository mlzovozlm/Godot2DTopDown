extends Actor

const MODE = {
	"KEY": 0,
	"MOUSE": 1
}

var move_mode;
var last_click_position := Vector2.ZERO;
var position_update_step = 0.5;
onready var position_timer := $PositionTimer;
onready var last_position = get_position();

func _ready():
	position_timer.set_wait_time(position_update_step);
	position_timer.set_one_shot(false);
	position_timer.connect("timeout", self, "stop_moving_in_place");
	position_timer.start();
	
func stop_moving_in_place() -> void:
	var current_position = get_position();
	if abs(last_position.x - current_position.x) < 2 and \
	abs(last_position.y - current_position.y) < 2:
		direction = Vector2.ZERO;
	last_position = current_position;
	
func _physics_process(delta) -> void:
	direction = get_direction();
	redirect_if_bumped();
	velocity = speed * direction.normalized();
	velocity = move_and_slide(velocity);
	if get_distance(get_position(), last_click_position) < 3:
		direction = Vector2.ZERO; 

func redirect_if_bumped():
	if move_mode == MODE.MOUSE:
		direction = last_click_position - get_position();
		
func get_distance(a: Vector2, b: Vector2) -> float:
	return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));
	
func get_direction() -> Vector2:
	var new_direction;
	if move_mode == 1:
		new_direction = direction;
	else: 
		new_direction = Vector2.ZERO;
	if Input.is_action_pressed("move_click"):
		move_mode = MODE.MOUSE;
		var mouse_position = get_global_mouse_position();
		new_direction = (mouse_position - get_position());
		last_click_position = mouse_position;
	if Input.is_action_pressed("move_left"):
		move_mode = MODE.KEY;
		new_direction.x = -1; 
	if Input.is_action_pressed("move_right"):
		move_mode = MODE.KEY;
		new_direction.x = 1;
	if Input.is_action_pressed("move_up"):
		move_mode = MODE.KEY;
		new_direction.y = -1;
	if Input.is_action_pressed("move_down"):
		move_mode = MODE.KEY;
		new_direction.y = 1;
	return new_direction;
   

