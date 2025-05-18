extends CharacterBody3D
@export var speed = 14
@export var fall_acceleration = 75
@export var jump_impulse = 5
@onready var anim_tree : AnimationTree = $"Pivot/AnimationTree"
var active = true
var is_skating = false
var target_velocity = Vector3.ZERO
var original_basis 
enum anim {IDLE, SKATE}
var cur_anim = anim.IDLE
var skate_val = 0.0
var blend_speed = 3.0
func update_tree(): 
	anim_tree["parameters/Blend2/blend_amount"] = skate_val
func handle_animations(delta):
	match cur_anim:
		anim.IDLE:
			skate_val = lerpf(skate_val,0,blend_speed*delta)
		anim.SKATE:
			skate_val = lerpf(skate_val,1,blend_speed*delta)

func _physics_process(delta: float) -> void:
	if is_skating:
		cur_anim = anim.SKATE
	else:
		cur_anim = anim.IDLE
	update_tree()
	handle_animations(delta)
	original_basis = $Pivot.basis
	if active:
		$Pivot.basis = original_basis
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
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			target_velocity.y = jump_impulse*3
			direction.y = 0
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	velocity = target_velocity
	
	move_and_slide()
