extends RigidBody3D

@export var speed: float = 50.0
@export var lifetime: float = 3.0

var life_timer := 0.0

func _ready():
	linear_velocity = -global_transform.basis.z * speed

func _physics_process(delta):
	life_timer += delta
	if life_timer > lifetime:
		queue_free()

func _on_Bullet_body_entered(body):
	if body.name != "Player":
		queue_free()
