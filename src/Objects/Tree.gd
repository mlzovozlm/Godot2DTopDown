extends KinematicBody2D

var choppable := false;
export var hp := 300;
export var chop_hp := 10;

# Called when the node enters the scene tree for the first time.
func _ready() ->void:
	pass # Replace with function body.

func _on_PlayerDetector_body_entered(body) -> void:
	choppable = true;

func _on_Tree_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.is_pressed() \
	and choppable:
		chopped();

func chopped() -> void:
	if hp > 0:
		$AnimationPlayer.play("shake");
		hp -= chop_hp * get_physics_process_delta_time();
	else:
		queue_free();
