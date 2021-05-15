extends Camera2D

var zoom_min := Vector2(0.5000001,0.5000001);
var zoom_max := Vector2(4,4);
var zoom_speed := Vector2(0.2, 0.2);
var des_zoom := zoom;

func _process(delta) -> void:
	zoom = lerp(zoom, des_zoom, 0.2);
	
func _input(event) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				if des_zoom > zoom_min:
					des_zoom -= zoom_speed;
			if event.button_index == BUTTON_WHEEL_DOWN:
				if des_zoom < zoom_max:
					des_zoom += zoom_speed;
