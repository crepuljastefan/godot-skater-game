extends VehicleBody3D
var player
var camera
@export var max_steer = 1
@export var ENGINE_POWER = 300
var target_velocity = Vector3.ZERO
var fall_acceleration = 70
var is_player_attached = false
func mount_player():
	if Input.is_action_just_pressed("mount_vehicle"):
		is_player_attached = true
		player.active = false
		position = player.position
func _physics_process(delta: float) -> void:
	player = $"../Player"
	mount_player()
	if is_player_attached:
		print("Ok!")
		steering = move_toward(steering, Input.get_axis("move_left", "move_right") * max_steer, delta * 10)
		engine_force = Input.get_axis("move_back", "move_forward") * ENGINE_POWER
		print("Engine: ", engine_force, " | Steer: ", steering)
		print("Velocity: ", linear_velocity)
		player.position = position + Vector3(0, 1, 0)
