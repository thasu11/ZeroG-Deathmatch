extends RigidBody3D

@export var speed: float = 10.0
@export var damage: int = 20

func _ready():
	# Fire the bullet forward
	linear_velocity = -global_transform.basis.z * speed
	
	# Enable contact monitoring
	contact_monitor = true
	max_contacts_reported = 1



func _physics_process(delta):
	if get_contact_count() > 0:
		queue_free()

	# Optional: kill after 3 seconds
	$Timer.start(3)

func _on_timer_timeout():
	queue_free()

func _integrate_forces(state):
	for contact_i in range(state.get_contact_count()):
		var collider = state.get_contact_collider_object(contact_i)
		
		if collider and collider.has_method("apply_damage"):
			collider.apply_damage(damage)
		
		# Bullet hits something, disappear
		queue_free()
