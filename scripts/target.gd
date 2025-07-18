extends StaticBody3D
@export var health: int = 100

func apply_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()

func die():
	queue_free() # or play animation or whatever
