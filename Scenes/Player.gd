extends CharacterBody3D
class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera = $Camera3D
@onready var raycast = $Camera3D/RayCast3D
@onready var tooltip_label = $UI/TooltipLabel

var mouse_sensitivity = 0.002
var is_active = true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_active(true)

func _input(event):
	if not is_active:
		return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -deg_to_rad(80), deg_to_rad(80))
	elif event is InputEventScreenDrag:
		# Tylko prawa połowa ekranu obraca kamerą
		if event.position.x > get_viewport().get_visible_rect().size.x / 2:
			rotate_y(-event.relative.x * mouse_sensitivity)
			camera.rotate_x(-event.relative.y * mouse_sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, -deg_to_rad(80), deg_to_rad(80))

func _physics_process(delta):
	if not is_active:
		return
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	# Handle RayCast
	var collider = raycast.get_collider()
	if collider and collider.has_method("get_interaction_text"):
		tooltip_label.text = collider.get_interaction_text()
		tooltip_label.show()
		
		if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("click"):
			if collider.has_method("interact"):
				collider.interact(self)
	else:
		tooltip_label.hide()

func set_active(active: bool):
	is_active = active
	set_physics_process(active)
	camera.current = active
	visible = active
	if active:
		$UI.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		$UI.hide()
