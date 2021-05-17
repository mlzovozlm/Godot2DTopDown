extends KinematicBody2D

var choppable := false;
export var hp := 300;
export var chop_hp := 10;
onready var aging_timer := $AgingTimer;
var age_max := 600;

func _ready():
	aging_timer.set_wait_time(age_max);
	aging_timer.set_one_shot(true);
	aging_timer.connect("timeout", self, "die");
	aging_timer.start();
	
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
		die();
		
func die():
	$CollisionShape2D.set_deferred("disabled", true);
	queue_free();

func _on_VisibleArea_body_entered(body):
	visible = true;

func _on_VisibleArea_body_exited(body):
	visible = false;
