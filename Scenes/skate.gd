extends RigidBody3D
var player
var camera
@export var max_steer = 1
@export var max_speed = 50
@export var ENGINE_POWER = 20
@onready var anim_player : AnimationPlayer  = $AnimationPlayer
@onready var skate_anim : AnimationTree
var progress = 0

@export var speed := 10.0
@export var acceleration := 10.0
var last_dir = 0
var grinding = false
@export var jump_strength := 400.0
var forward_dir = 0
var is_turning = false
var original_velocity
var input_direction := Vector3.ZERO
var target_velocity := Vector3.ZERO
var fall_acceleration = 20
var is_player_attached = false
var original_rotation
var original_basis
var dir = Vector3.ZERO
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
func get_grind_data(delta):
	var arr = []
	var rail
	if $FrontGrind.is_colliding():
		if $FrontGrind.get_collider(0).is_in_group("Rail"):
			rail = $FrontGrind.get_collider(0).get_parent().get_parent()
		
			arr.append("front")
	if $BackGrind.is_colliding():
		if $BackGrind.get_collider(0).is_in_group("Rail"):
			rail = $BackGrind.get_collider(0).get_parent().get_parent()
		
			arr.append("back")
	return [arr, rail] 
func handle_grind(grind_data, delta):
	print(freeze)
	var sides = grind_data[0]
	var direction_after = 0
	if sides.size() > 0:
		var rail = grind_data[1]
		if rail != null:
			var end 
			var prev_pos = position
			var start
			var predicted_progress = 0
			var skate_len
			end = rail.get_node("End").global_position
			start = rail.get_node("Start").global_position
			var len = (end-start).length()
			print(len)
			var start_pos = start
			var end_pos = end
			var skate_flat = Vector2(global_position.x, global_position.z)
			skate_len = ($Back.position - $Front.position).length()
			if not grinding:
				var skate_dir = -global_transform.basis.z.normalized()
				print("skate len", skate_len)
				dir = (end - start).normalized()
				dir.y = 0
				end_pos = end
				start_pos = start
				dir = dir.normalized()
				print("Oovoo", skate_dir.dot(dir))
				if(skate_dir.dot(dir) > 0):
					dir = -dir
					start_pos = end
					end_pos = start
				progress = (position - start_pos).length()
				grinding = true
			
			else:
				#prev_pos = position - step
				#print(position.distance_to(end))
				#print("PROGRES", progress)
				var step = dir * delta * 15
				freeze = RigidBody3D.FREEZE_MODE_KINEMATIC
				position += step
				progress += prev_pos.distance_to(position)
				if progress + skate_len >= len:
					freeze = false
					grinding = false
					progress = 0
					apply_central_force(-transform.basis.z * -1100)
				print("P", progress)
		else:
			freeze = false
			print("he")
	else:
		freeze = false
		print("ovde")
		position.y += 20
		pass
	#print("hoj")
	pass
func enable_collision():
	var collisions = [$CollisionShape3D,$CollisionShape3D2,$CollisionShape3D3,$CollisionShape3D4,$CollisionShape3D5]
	for collision in collisions:
		collision.disabled = false
func disable_collision():
	var collisions = [$CollisionShape3D,$CollisionShape3D2,$CollisionShape3D3,$CollisionShape3D4,$CollisionShape3D5]
	for collision in collisions:
		collision.disabled = true
func get_ramp_collision():
	var raycasts = [$RayCast3D,$RayCast3D2,$RayCast3D3,$RayCast3D4]
	var avg_steepness = 0
	var avg_dir = 0
	for raycast in raycasts:
		avg_steepness += raycast.get_collision_normal().y
		avg_dir += raycast.get_collision_normal().z
	return Vector3(0,1 - avg_steepness/raycasts.size(), avg_dir/raycasts.size())
func skating(delta):
	is_turning = false
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.y = Input.get_axis("drive", "brake")
	var forward_speed = -linear_velocity.dot(transform.basis.z)
	if forward_speed > 0.01:
		forward_dir = 1
		last_dir = 1
	elif forward_speed < -0.01: 
		forward_dir = -1
		last_dir = -1
	else:
		if last_dir == 1:
			if Input.is_action_just_released("move_left") or Input.is_action_just_released("move_right"):
				print("IDEMOOOOO")
				forward_dir = -1
	#print(last_dir," ", forward_dir)
	
	#print(get_ramp_collision())
	if is_on_floor():
		if get_ramp_collision().y > 0.1:
			#apply_central_force(50 * -transform.basis.sz * get_ramp_collision().z)
			apply_central_force(transform.basis.z * 20 * get_ramp_collision().z)
			apply_central_force(input.y * 1 * ENGINE_POWER * -transform.basis.z)
		if linear_velocity.length() < 20:
			apply_central_force(input.y * ENGINE_POWER* -transform.basis.z)
		if Input.is_action_pressed("move_left"):
			original_velocity = linear_velocity
			is_turning = true
			#apply_central_force(input.y * ENGINE_POWER * transform.basis.z)
			
			var curr_speed = linear_velocity.length()
			rotation.y += 0.04 * -forward_dir
			linear_velocity = -forward_dir * transform.basis.z * curr_speed + Vector3(0,linear_velocity.y,0)
			linear_velocity.y = original_velocity.y  # preserve verical velocity
		if Input.is_action_pressed("move_right"):
			original_velocity = linear_velocity

			is_turning = true
			#apply_central_force(input.y * ENGINE_POWER * transform.basis.z)
			var curr_speed = linear_velocity.length()
			rotation.y -= 0.04 * -forward_dir
			linear_velocity = -forward_dir * transform.basis.z * curr_speed + Vector3(0,linear_velocity.y,0)
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
		var grinding = get_grind_data(delta)
		if grinding[0].size() > 0:
			handle_grind(grinding, delta)
		if Input.get_axis("brake","drive") != 0:
			player.is_skating = true
			
		else:
			player.is_skating = false
			#print(engine_force)
		#freeze = true
		#position.y = 10
		
		var pivot = player.get_node("Pivot")
		#print("player: ", pivot.rotation.x, " skate: ", rotation.x)
	

		pivot.rotation.x = -rotation.x
		pivot.rotation.y = rotation.y
		player.global_position = global_position + Vector3(0,0.5,0)
	else:
		velocity_label.visible = false	
