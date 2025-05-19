extends RigidBody3D
var player
var camera
@export var max_steer = 1
@export var max_speed = 50
@export var ENGINE_POWER = 20
@onready var anim_player : AnimationPlayer  = $AnimationPlayer
@onready var skate_anim : AnimationTree

@export var speed := 10.0
@export var acceleration := 10.0
@export var jump_strength := 300.0
var is_turning = false
var original_velocity
var input_direction := Vector3.ZERO
var target_velocity := Vector3.ZERO
var fall_acceleration = 20
var is_player_attached = false
var original_rotation
var original_basis
var velocity_label
var steering
var engine_force
var direction = Vector3.ZERO
func _ready() -> void:
	player = $"../Player"
	skate_anim = player.get_node("Pivot").get_node("character").get_node("AnimationTree")
	velocity_label = $CanvasLayer/Label
	velocity_label.visible = false
	camera = get_parent().get_node("Player").get_child(2)
func is_on_floor() -> bool:
	var raycasts = [$RayCast3D,$RayCast3D2,$RayCast3D3,$RayCast3D4]
	for raycast in raycasts:
		if raycast.is_colliding():
			return true
	return false
func get_ramp_collision():
	var raycasts = [$RayCast3D,$RayCast3D2,$RayCast3D3,$RayCast3D4]
	var avg_steepness = 0
	for raycast in raycasts:
		avg_steepness += raycast.get_collision_normal().y
	return 1 - avg_steepness/raycasts.size()
func skating(delta):
	is_turning = false
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.y = Input.get_axis("drive", "brake")
	var forward_speed = -linear_velocity.dot(transform.basis.z)
	if forward_speed > 0.01:
		forward_speed = 1
	elif forward_speed < -0.01: 
		forward_speed = -1
	print(get_ramp_collision())
	if is_on_floor():
		if get_ramp_collision() > 0.1:
			print(input.y)
			apply_central_force(input.y * 0.5 * ENGINE_POWER * -transform.basis.z)
		if linear_velocity.length() < 20:
			apply_central_force(input.y * ENGINE_POWER* -transform.basis.z)
		if Input.is_action_pressed("move_left"):
			original_velocity = linear_velocity
			is_turning = true
			#apply_central_force(input.y * ENGINE_POWER * transform.basis.z)
			
			var curr_speed = linear_velocity.length()
			rotation.y += 0.04
			linear_velocity = -forward_speed * transform.basis.z * curr_speed + Vector3(0,linear_velocity.y,0)
			linear_velocity.y = original_velocity.y  # preserve verical velocity
		if Input.is_action_pressed("move_right"):
			original_velocity = linear_velocity

			is_turning = true
			#apply_central_force(input.y * ENGINE_POWER * transform.basis.z)
			var curr_speed = linear_velocity.length()
			rotation.y -= 0.04
			linear_velocity = -forward_speed * transform.basis.z * curr_speed + Vector3(0,linear_velocity.y,0)
			linear_velocity.y = original_velocity.y  # preserve vertical velocity

	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():			
			player.cur_anim = player.anim.IDLE
			anim_player.play("ollie")
			apply_central_force(Vector3.UP * jump_strength)
func play_anim(anim: String):
	print($Timer2.time_left)
	anim_player.play(anim)
	$Timer2.stop()
	print(anim)
	
func mount_player():
	if player.active:
		if Input.is_action_just_pressed("mount_vehicle"):
			original_basis = player.get_child(0).basis
			original_rotation = player.rotation.y
			is_player_attached = true
			player.active = false
			position = player.position
			position.y += 0.5
			rotation.y = player.rotation.y
			player.rotation.y = 3
func _process(delta: float) -> void:
	velocity_label.text = "Velocity: " + str(floor(linear_velocity.length()))
func _physics_process(delta: float) -> void:
	mount_player()
	if is_player_attached:
		velocity_label.visible =  true
		if Input.is_action_just_pressed("ui_copy"):
			player.rotation.y = -player.rotation.y
			camera.rotation.y = -camera.rotation.y
		if Input.is_action_just_pressed("ui_cancel"):
			player.active = true
			player.position = Vector3(0,0,0)
			player.rotation.y = original_rotation
			
			is_player_attached = false
			
		if camera.camera_locked:
			if is_on_floor():
				if Input.is_action_just_pressed("ollie_down"):
					$Timer.start(0.2)
						
				if Input.is_action_just_pressed("ollie_up") and not $Timer.is_stopped():
					$Timer.stop()
					player.cur_anim = player.anim.IDLE
					anim_player.play("ollie")
					apply_central_force(Vector3.UP * jump_strength)
					$Timer2.start(0.017)
			if not is_on_floor() and not $Timer2.is_stopped():
				if Input.is_action_just_pressed("move_forward"):
					play_anim("kickflip")
				elif Input.is_action_just_pressed("move_right"):
					play_anim("heel!!")
				elif Input.is_action_just_pressed("move_back"):
					play_anim("fs_shuv")
		elif camera.camera_locked2:
			if is_on_floor():
				if Input.is_action_just_pressed("ollie_down"):
					$Timer.start(0.2)
				if Input.is_action_just_pressed("ollie_up") and not $Timer.is_stopped():
						player.cur_anim = player.anim.IDLE
						anim_player.play("ollie")
						apply_central_force(Vector3.UP * jump_strength)
						$Timer2.start(0.017)
						print($Timer.is_stopped())
					
			if not is_on_floor() and not $Timer2.is_stopped():
				if Input.is_action_just_pressed("move_forward"):
					play_anim("lazerflip")
				elif Input.is_action_just_pressed("move_right"):
					play_anim("trifip")
				elif Input.is_action_just_pressed("move_back"):
					play_anim("dopefein")
				elif Input.is_action_just_pressed("move_left"):
					play_anim("shuvit")
				
				
			
		skating(delta)
		if Input.get_axis("brake","drive") != 0:
			player.is_skating = true
			
		else:
			player.is_skating = false
			#print(engine_force)
		#freeze = true
		#position.y = 10
		
		var pivot = player.get_node("Pivot")
		print("player: ", pivot.rotation.x, " skate: ", rotation.x)
	

		pivot.rotation.x = -rotation.x
		pivot.rotation.y = rotation.y
		player.global_position = global_position + Vector3(0,0.5,0)
	else:
		velocity_label.visible = false	
