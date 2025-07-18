extends CharacterBody3D

@export_group("Movement")
@export var thrust_force: float = 7.0
@export var boost_force: float = 10.0
@export var boost_cooldown: float = 2.0

@export_group("Camera Clamp Limits")
@export var first_person_pitch_limit: float = PI / 2.2  # Allows more vertical look in first person
@export var third_person_pitch_limit: float = PI / 3.0  # Tighter vertical look in third person

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25

var can_boost = true
var _camera_input_direction := Vector2.ZERO
var is_first_person: bool = true

var health := 100

@onready var _camera_pivot: Node3D = %camerapivot
@onready var _first_person_camera: Camera3D = %FirstPersonCamera
@onready var _third_person_camera: Camera3D = %ThirdPersonCamera
@onready var _timer: Timer = $Timer

@export var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")

@export var fire_point: Node3D
@export var _is_first_person: bool = true  # Controlled externally (player input toggle)

func _process(delta):
	update_gun_visibility()
	handle_shooting()

func update_gun_visibility():
	if _is_first_person:
		$camerapivot/FirstPersonCamera/GunSocket_FP/"blaster-g".visible = true
		$camerapivot/ThirdPersonCamera/GunSocket_TP/"blaster-g".visible = false
	else:
		$camerapivot/FirstPersonCamera/GunSocket_FP/"blaster-g".visible = false
		$camerapivot/ThirdPersonCamera/GunSocket_TP/"blaster-g".visible = true
func fire_bullet():
	if bullet_scene and fire_point:
		var bullet = bullet_scene.instantiate()
		bullet.global_transform = fire_point.global_transform
		get_tree().current_scene.add_child(bullet)
		print("Bang!")


func handle_shooting():
	if Input.is_action_just_pressed("shoot"):
		fire_bullet()


func apply_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()

func die():
	queue_free() # or play animation or whatever




func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_timer.timeout.connect(_on_Timer_timeout)
	_first_person_camera.current = true
	_third_person_camera.current = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("toggle_view"):
		toggle_camera()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_camera_input_direction = event.relative * mouse_sensitivity

func _physics_process(delta: float) -> void:
	handle_camera_look(delta)
	handle_movement(delta)
	handle_boost()
	move_and_slide()

func handle_camera_look(delta: float) -> void:
	var pitch_limit: float
	if is_first_person:
		pitch_limit = first_person_pitch_limit
	else:
		pitch_limit = third_person_pitch_limit


	_camera_pivot.rotation.x -= _camera_input_direction.y * delta  # Inverted Y
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -pitch_limit, pitch_limit)

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

func toggle_camera():
	is_first_person = !is_first_person
	_first_person_camera.current = is_first_person
	_third_person_camera.current = !is_first_person

func _on_Timer_timeout():
	can_boost = true
