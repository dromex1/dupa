extends CanvasLayer

@onready var tab_container = $Panel/MarginContainer/VBoxContainer/TabContainer
var active_player = null
var bought_upgrades = {}

var categories = {
	"Silnik": ["Moc Silnika", "Przyspieszenie", "Moment Obrotowy"],
	"Sterowanie": ["Szybkość Skrętu", "Kąt Skrętu", "Stabilność"],
	"Opony": ["Przyczepność Przód", "Przyczepność Tył", "Tarcie Boczne"],
	"Hamulce": ["Siła Hamowania", "Balans", "Ostrzejsze Hamowanie"]
}

func _ready():
	hide()
	generate_upgrades()

func generate_upgrades():
	for cat_name in categories.keys():
		var margin = MarginContainer.new()
		margin.name = cat_name
		margin.add_theme_constant_override("margin_top", 15)
		margin.add_theme_constant_override("margin_left", 15)
		margin.add_theme_constant_override("margin_right", 15)
		margin.add_theme_constant_override("margin_bottom", 15)
		
		var scroll = ScrollContainer.new()
		scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		margin.add_child(scroll)
		
		var grid = GridContainer.new()
		grid.columns = 3
		grid.add_theme_constant_override("h_separation", 20)
		grid.add_theme_constant_override("v_separation", 20)
		grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.add_child(grid)
		
		var stats = categories[cat_name]
		for stat_name in stats:
			for level in range(1, 6): # 4 kategorie * 3 statystyki * 5 poziomów = 60 ulepszeń!
				var btn = Button.new()
				var up_id = stat_name + "_" + str(level)
				btn.text = stat_name + "\nPoz." + str(level)
				btn.custom_minimum_size = Vector2(250, 70)
				btn.add_theme_font_size_override("font_size", 16)
				btn.pressed.connect(_on_upgrade_pressed.bind(btn, stat_name, level, up_id))
				grid.add_child(btn)
				
		tab_container.add_child(margin)

func open(player):
	active_player = player
	if active_player:
		active_player.set_active(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	show()

func close():
	hide()
	if active_player:
		active_player.set_active(true)

func _on_upgrade_pressed(btn: Button, stat_name, level, up_id):
	if bought_upgrades.has(up_id): return
	
	bought_upgrades[up_id] = true
	btn.text = "Wykupiono"
	btn.disabled = true
	
	var car = get_node_or_null("/root/Main/car")
	if not car: return
	
	# Znacząca modyfikacja statystyk pojazdu
	if stat_name == "Moc Silnika":
		car.engine_force_value += 70 * level
	elif stat_name == "Przyspieszenie":
		car.engine_force_value += 40 * level
	elif stat_name == "Szybkość Skrętu":
		car.STEER_SPEED += 0.5 * level
	elif stat_name == "Kąt Skrętu":
		car.STEER_LIMIT += 0.15 * level
	elif stat_name == "Przyczepność Przód":
		var fl = car.get_node("wheel_front_left")
		var fr = car.get_node("wheel_front_right")
		if fl: fl.wheel_friction_slip += 0.5 * level
		if fr: fr.wheel_friction_slip += 0.5 * level
	elif stat_name == "Przyczepność Tył":
		var rl = car.get_node("wheel_rear_left")
		var rr = car.get_node("wheel_rear_right")
		if rl: rl.wheel_friction_slip += 0.5 * level
		if rr: rr.wheel_friction_slip += 0.5 * level

func _on_close_button_pressed():
	close()
