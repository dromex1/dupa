extends CanvasLayer

@onready var joy_bg = $Control/JoystickBG
@onready var joy_knob = $Control/JoystickBG/Knob
var touch_id = -1
var max_length = 60.0
var joy_center = Vector2.ZERO

var current_action_x = ""
var current_action_y = ""

func _ready():
	# Pokazujemy tylko jesli obslugiwany jest dotyk
	if not OS.has_feature("mobile") and not ProjectSettings.get_setting("input_devices/pointing/emulate_touch_from_mouse"):
		hide()
	
	joy_bg.hide() # Ukrywamy poki nie dotkniemy ekranu
	max_length = joy_bg.size.x / 2

func _input(event):
	if event is InputEventScreenTouch:
		if event.position.x < get_viewport().get_visible_rect().size.x / 2:
			if event.pressed and touch_id == -1:
				touch_id = event.index
				joy_bg.global_position = event.position - joy_bg.size / 2
				joy_center = event.position
				joy_knob.position = joy_bg.size / 2
				joy_bg.show()
			elif not event.pressed and event.index == touch_id:
				touch_id = -1
				joy_bg.hide()
				release_all()
	
	elif event is InputEventScreenDrag:
		if event.index == touch_id:
			var dir = event.position - joy_center
			if dir.length() > max_length:
				dir = dir.normalized() * max_length
			joy_knob.position = (joy_bg.size / 2) + dir
			
			update_actions(dir / max_length)

func update_actions(vec: Vector2):
	var th = 0.2
	
	var next_x = ""
	if vec.x > th: next_x = "right"
	elif vec.x < -th: next_x = "left"
	
	var next_y = ""
	if vec.y > th: next_y = "backward"
	elif vec.y < -th: next_y = "forward"
	
	if next_x != current_action_x:
		if current_action_x != "": release_action(current_action_x)
		if next_x != "": press_action(next_x)
		current_action_x = next_x
		
	if next_y != current_action_y:
		if current_action_y != "": release_action(current_action_y)
		if next_y != "": press_action(next_y)
		current_action_y = next_y

func press_action(action_name):
	var ev = InputEventAction.new()
	ev.action = action_name
	ev.pressed = true
	Input.parse_input_event(ev)

func release_action(action_name):
	var ev = InputEventAction.new()
	ev.action = action_name
	ev.pressed = false
	Input.parse_input_event(ev)

func release_all():
	if current_action_x != "": release_action(current_action_x)
	if current_action_y != "": release_action(current_action_y)
	current_action_x = ""
	current_action_y = ""

func _on_action_button_button_down():
	press_action("interact")
	press_action("exit_car")
	press_action("click")

func _on_action_button_button_up():
	release_action("interact")
	release_action("exit_car")
	release_action("click")
