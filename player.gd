extends CharacterBody3D
@export var speed = 14
@export var fall_acceleration = 75
@export var jump_impulse = 20
var active = true
var target_velocity = Vector3.ZERO

func _physics_process(delta: float) -> void:
	if active:
		movement(delta)
	else:
		pass
func movement(delta: float) -> void:
	var spring_arm = get_node("SpringArm3D")
	var direction = Vector3.ZERO
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.y = Input.get_axis("move_forward", "move_back")
	direction = Vector3(input.x,0,input.y).rotated(Vector3.UP, spring_arm.rotation.y)
		
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		var target_basis = Basis().looking_at(direction, Vector3.UP)
		$Pivot.basis = $Pivot.basis.slerp(target_basis, delta * 10)
	
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	if is_on_floor and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse
		direction.y = 0
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	velocity = target_velocity
	
	move_and_slide()
