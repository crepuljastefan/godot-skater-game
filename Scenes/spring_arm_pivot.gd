extends Node3D
@export var mouse_sens: float = 0.005
@export var controller_sens: float = 1.5
@onready var player: Node3D = get_parent().get_node("Pivot")
#@onready var camera: Camera3D = get_child(0w )
@export var camera_locked = false
@export var camera_locked2 = false
var input_rotation := Vector2.ZERO
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func _process(delta: float) -> void:
	if Input.is_action_pressed("lock_camera"):
		camera_locked = true
	if Input.is_action_just_released("lock_camera"):
		camera_locked = false
	if Input.is_action_pressed("lock_camera2"):
		camera_locked2 = true
	if Input.is_action_just_released("lock_camera2"):
		camera_locked2 = false
	if not camera_locked and not camera_locked2:
		
		var controller_input := Vector2.ZERO
		if Input.is_action_pressed("camera_left"):
			controller_input.y += 1

		if Input.is_action_pressed("camera_right"):
			controller_input.y -= 1

		if Input.is_action_pressed("camera_up"):
			controller_input.x -= 1

		if Input.is_action_pressed("camera_down"):
			controller_input.x += 1
		
		input_rotation += controller_input * controller_sens * delta
		$SpringArm3D.input_rotation.x = input_rotation.x
		rotation.y  += input_rotation.y
		#rotation.x += input_rotation.x
		rotation.y = wrapf(rotation.y, 0.0, TAU)
		#rotation.x = clamp(rotation.x, -PI/2, PI/6)
		input_rotation = Vector2.ZERO

		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sens
		rotation.y = wrapf(rotation.y, 0.0, TAU)
		#rotation.x -= event.relative.y * mouse_sens
		#rotation.x = clamp(rotation.x, -PI/2,PI/6)
		
		
