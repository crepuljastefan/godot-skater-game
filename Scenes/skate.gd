extends VehicleBody3D
var player
var camera
@export var max_steer = 1
@export var max_speed = 50
@export var ENGINE_POWER = 200
@onready var anim_player : AnimationPlayer  = $AnimationPlayer
var target_velocity = Vector3.ZERO
var fall_acceleration = 20
var is_player_attached = false
var original_rotation
var velocity_label
func _ready() -> void:
	player = $"../Player"
	velocity_label = $CanvasLayer/Label
	velocity_label.visible = false
	original_rotation = player.rotation.normalized()
	camera = get_parent().get_node("Player").get_child(3)
func is_on_floor() -> bool:
	var raycasts = [$RayCast3D,$RayCast3D2,$RayCast3D3,$RayCast3D4]
	for raycast in raycasts:
		if not raycast.is_colliding():
			return false
	return true
func mount_player():
	
	if Input.is_action_just_pressed("mount_vehicle"):
		is_player_attached = true
		player.active = false
		position = player.position
		player.position = position + Vector3(0,0.5,0)
func _process(delta: float) -> void:
	velocity_label.text = "Velocity: " + str(floor(linear_velocity.length()))
func _physics_process(delta: float) -> void:
	mount_player()
	original_rotation = player.rotation
	if is_player_attached:
		velocity_label.visible =  true

		if Input.is_action_just_pressed("ui_cancel"):
			player.active = true
			player.position = Vector3(0,0,0)
			player.rotation = original_rotation
			is_player_attached = false
			
		if Input.is_action_just_pressed("jump"):
			anim_player.play("ollie")
			apply_central_impulse(Vector3(0,1000,0))
		if camera.camera_locked:
			if Input.is_action_just_pressed("ollie_down"):
				$Timer.start(0.2)
			if Input.is_action_just_pressed("ollie_up") and not $Timer.is_stopped():
				anim_player.play("ollie")
				apply_central_impulse(Vector3(0,1000,0))
				$Timer.is_stopped()
				$Timer.start(0.2)
			if not is_on_floor() and not $Timer.is_stopped():
				if Input.is_action_just_pressed("move_forward"):
					anim_player.play("kickflip")
					$Timer.stop()
					print("kickflip")
				elif Input.is_action_just_pressed("move_right"):
					anim_player.play("heel!!")
					$Timer.stop()
					print("heel")
				elif Input.is_action_just_pressed("move_back"):
					anim_player.play("fs_shuv")
					print("fs_shuv")
					$Timer.stop()
		elif camera.camera_locked2:
			if Input.is_action_just_pressed("ollie_down"):
				$Timer.start(0.2)
			if Input.is_action_just_pressed("ollie_up") and not $Timer.is_stopped():
				anim_player.play("ollie")
				apply_central_impulse(Vector3(0,1000,0))
				$Timer.stop()
				$Timer.start(0.2)
			if not is_on_floor() and not $Timer.is_stopped():
				if Input.is_action_just_pressed("move_forward"):
					anim_player.play("lazerflip")
					print("lazerflip")
					$Timer.stop()
				elif Input.is_action_just_pressed("move_right"):
					anim_player.play("trifip")
					print("triflip")
					$Timer.stop()
				elif Input.is_action_just_pressed("move_back"):
					anim_player.play("dopefein")
					print("dopefein")
					$Timer.stop()
				elif Input.is_action_just_pressed("move_left"):
					anim_player.play("shuvit")
					print("shuvit")
					$Timer.stop()
				
				
			
			
			
		steering = move_toward(steering, Input.get_axis("move_right", "move_left") * max_steer, delta * 10)
		if linear_velocity.length() < 30.0:
			engine_force = Input.get_axis("brake", "drive") * ENGINE_POWER
			
		else:
			engine_force = 0

		player.position = position
		player.rotation.y = rotation.y
		#player.rotation = rotation
		
	else:
		velocity_label.visible = false	
