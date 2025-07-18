extends CharacterBody3D

@export_group("Movement")
@export var thrust_force: float = 10.0
@export var boost_force: float = 25.0
@export var boost_cooldown: float = 2.0

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25

var can_boost = true
var _camera_input_direction := Vector2.ZERO

@onready var _camera_pivot: Node3D = %camerapivot
@onready var _timer: Timer = $Timer

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_timer.timeout.connect(_on_Timer_timeout)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_camera_input_direction = event.relative * mouse_sensitivity

func _physics_process(delta: float) -> void:
	handle_camera_look(delta)
	handle_movement(delta)
	handle_boost()
	move_and_slide()  # No argument needed in Godot 4

func handle_camera_look(delta: float) -> void:
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -PI / 2.5, PI / 3.0)
	rotation.y -= _camera_input_direction.x * delta
	_camera_input_direction = Vector2.ZERO

func handle_movement(delta: float):
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
		velocity += direction.normalized() * thrust_force * delta

func handle_boost():
	if can_boost and Input.is_action_just_pressed("boost"):
		var forward = -global_transform.basis.z
		velocity += forward * boost_force
		can_boost = false
		_timer.start()

func _on_Timer_timeout():
	can_boost = true
