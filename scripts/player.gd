extends RigidBody3D

@export var thrust_force: float = 10.0
@export var boost_force: float = 25.0
@export var boost_cooldown: float = 2.0

var can_boost = true

func _physics_process(delta):
	handle_movement(delta)
	handle_boost()
	
func handle_movement(delta):
	var direction = Vector3.ZERO
	var basis = global_transform.basis

	if Input.is_action_pressed("move_forward"):
		direction -= basis.z
	if Input.is_action_pressed("move_backward"):
		direction += basis.z
	if Input.is_action_pressed("move_left"):
		direction -= basis.x
	if Input.is_action_pressed("move_right"):
		direction += basis.x
	if Input.is_action_pressed("move_up"):
		direction += basis.y
	if Input.is_action_pressed("move_down"):
		direction -= basis.y

	if direction != Vector3.ZERO:
		apply_impulse(Vector3.ZERO, direction.normalized() * thrust_force)

func handle_boost():
	if can_boost and Input.is_action_just_pressed("boost"):
		var forward = -global_transform.basis.z
		apply_impulse(Vector3.ZERO, forward * boost_force)
		can_boost = false
		$Timer.start()



func _on_timer_timeout() -> void:
	can_boost = true
